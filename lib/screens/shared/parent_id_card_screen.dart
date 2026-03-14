import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../models/app_user.dart';

/// Virtual Gate Pass Screen
///
/// Digital ID card with school branding, QR code, and full-screen mode.
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';

class ParentIdCardScreen extends StatelessWidget {
  const ParentIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('grNo', isEqualTo: currentUser.email.split('@')[0])
          .snapshots(),
      builder: (context, snapshot) {
        // demo data fallback
        Student student = MockDataService.demoStudent;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          student = Student.fromMap(
            snapshot.data!.docs.first.data() as Map<String, dynamic>,
            snapshot.data!.docs.first.id,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text('Virtual Gate Pass'),
            backgroundColor: Colors.transparent, elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textOnDark, size: 20),
              onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(icon: const Icon(Icons.fullscreen, color: AppColors.textOnDark),
                onPressed: () => _showFullScreen(context, currentUser, student)),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildIdCard(currentUser, student),
            ),
          ),
        );
      }
    );
  }

  Widget _buildIdCard(AppUser parent, Student student) {
    final parentName = parent.displayName ?? 'Parent';
    final qrCodeId = 'DASTUR-QR-P-${student.grNo}-2024';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // School header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: AppColors.accent, size: 28),
            ),
            const SizedBox(height: 8),
            const Text(AppConstants.schoolShortName,
              style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center),
            const Text('Pune', style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 20),
        // Parent ID badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('PARENT GATE PASS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1, color: AppColors.primaryDark)),
        ),
        const SizedBox(height: 20),
        // Parent photo
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.accent.withValues(alpha: 0.15),
          backgroundImage: parent.photoUrl != null ? NetworkImage(parent.photoUrl!) : null,
          child: parent.photoUrl == null ? Text(parentName[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent)) : null,
        ),
        const SizedBox(height: 12),
        Text(parentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Parent of \${student.name}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Class \${student.fullClass}', style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        // QR Code placeholder
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.qr_code_2, size: 60, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(qrCodeId, style: const TextStyle(fontSize: 8, color: AppColors.textSubtle)),
          ]),
        ),
        const SizedBox(height: 14),
        Text('Linked Student GR No: \${student.grNo}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Valid: \${AppConstants.academicYear}', style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
      ]),
    );
  }

  void _showFullScreen(BuildContext context, AppUser parent, Student student) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          title: const Text('Show at Gate', style: TextStyle(color: AppColors.textOnDark)),
          leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textOnDark), onPressed: () => Navigator.pop(context)),
        ),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: _buildIdCard(parent, student))),
      ),
    ));
  }
}
