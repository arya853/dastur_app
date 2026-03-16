import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/photo_upload_service.dart';
import '../../services/mock_data_service.dart';

/// Profile Screen – shows information based on the current user role.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Role-based logic for profile fetching
    final studentData = authService.studentProfile;
    
    // If we have student data from login, use it. Otherwise, use StreamBuilder as fallback for refreshes/updates.
    return StreamBuilder<QuerySnapshot>(
      stream: (currentUser.role == 'parent' && studentData == null)
          ? FirebaseFirestore.instance
              .collection('students')
              .where('grNo', isEqualTo: currentUser.email.split('@')[0])
              .snapshots()
          : null,
      builder: (context, snapshot) {
        // Prepare display data
        Map<String, dynamic>? displayData = studentData;
        if (displayData == null && snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          displayData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        }

        // Final fallback to mock only if absolutely NO data exists (should not happen in production)
        if (displayData == null && !snapshot.hasData) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final student = Student.fromMap(
          displayData ?? MockDataService.demoStudent.toMap(),
          snapshot.hasData && snapshot.data!.docs.isNotEmpty ? snapshot.data!.docs.first.id : 'profile-user',
        );

        return Scaffold(
          appBar: const GradientAppBar(title: 'Profile', showBackButton: true),
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Student Header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  ),
                  child: Column(children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                          backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
                          child: student.photoUrl == null 
                              ? Text(student.name.isNotEmpty ? student.name[0] : 'S', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent)) 
                              : null,
                        ),
                        Container(
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            onPressed: () async {
                              final photoService = Provider.of<PhotoUploadService>(context, listen: false);
                              final url = await photoService.pickAndUploadPhoto(
                                collection: 'students',
                                documentId: snapshot.hasData ? snapshot.data!.docs.first.id : 'demo-student',
                                folder: 'student_photos',
                              );
                              if (url != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student photo updated!')));
                              }
                            },
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(student.name, style: const TextStyle(color: AppColors.textOnDark, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('GR No: ${student.grNo}', style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Student Information ──
                _infoCard('Student Details', [
                  _infoRow(Icons.badge, 'General Register No.', student.grNo),
                  _infoRow(Icons.class_, 'Class & Division', student.fullClass),
                  _infoRow(Icons.email, 'School Email', student.email),
                ]),
                const SizedBox(height: 12),

                // ── Parent Information ──
                if (student.parentDetails != null)
                  _infoCard('Parent Details', [
                    const SizedBox(height: 8),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: currentUser.photoUrl != null ? NetworkImage(currentUser.photoUrl!) : null,
                            child: currentUser.photoUrl == null 
                                ? Text((student.parentDetails!['name']?.isNotEmpty ?? false) ? student.parentDetails!['name'][0] : 'P', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary)) 
                                : null,
                          ),
                          Container(
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              onPressed: () async {
                                final photoService = Provider.of<PhotoUploadService>(context, listen: false);
                                final url = await photoService.pickAndUploadPhoto(
                                  collection: 'users',
                                  documentId: currentUser.uid,
                                  folder: 'parent_photos',
                                );
                                if (url != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parent photo updated!')));
                                }
                              },
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow(Icons.person, 'Parent Name', student.parentDetails!['name'] ?? 'N/A'),
                    _infoRow(Icons.phone, 'Contact Number', student.parentDetails!['phone'] ?? 'N/A'),
                    // Note: Parent Email is explicitly hidden per requirement
                  ]),
                
                const SizedBox(height: 16),
                
                // Virtual Gate Pass button for parents
                if (currentUser.role == 'parent')
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/parent-id-card'),
                      icon: const Icon(Icons.credit_card),
                      label: const Text('View Virtual Gate Pass'),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
      ]),
    );
  }
}
