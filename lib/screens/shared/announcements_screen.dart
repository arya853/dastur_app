import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/announcement.dart';
import '../../services/auth_service.dart';

/// Announcements Screen - clean feed layout showing all announcements.
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userRole = authService.currentUser?.role ?? 'parent';
    
    // Extract logical user class for filtering
    String? userClass;
    if (userRole == 'parent' && authService.studentProfile != null) {
      final cInfo = authService.studentProfile!['CLASS'] ?? authService.studentProfile!['className'];
      if (cInfo != null) userClass = cInfo.toString();
    } else if (userRole == 'teacher' && authService.teacherProfile != null) {
      final cInfo = authService.teacherProfile!['CLASS'];
      if (cInfo != null) userClass = cInfo.toString();
    }

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Announcements',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .where('isActive', isEqualTo: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          
          // Client-side filtering based on role and class
          final List<Announcement> visibleAnnouncements = [];
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final ann = Announcement.fromMap(data, doc.id);
            
            // Overrides for absolute admins
            if (userRole == 'admin') {
              visibleAnnouncements.add(ann);
              continue;
            }

            // Role filtering
            if (ann.targetRole != 'all' && ann.targetRole != '${userRole}s') {
              continue;
            }

            // Class filtering
            if (ann.targetClass != null && ann.targetClass != userClass) {
              continue;
            }

            visibleAnnouncements.add(ann);
          }

          if (visibleAnnouncements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No new announcements.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visibleAnnouncements.length,
            itemBuilder: (context, index) {
              final ann = visibleAnnouncements[index];
              return InkWell(
                onTap: () => Navigator.pushNamed(
                  context, 
                  '/announcement-detail', 
                  arguments: ann,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with type badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _typeColor(ann.type).withValues(alpha: 0.06),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _typeColor(ann.type).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_typeIcon(ann.type),
                                  color: _typeColor(ann.type), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ann.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            StatusChip(
                              label: ann.type.toUpperCase(),
                              color: _typeColor(ann.type),
                            ),
                          ],
                        ),
                      ),
                      // Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          ann.body,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Footer: date and author
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 13, color: AppColors.textSubtle),
                            const SizedBox(width: 4),
                            Text(
                              '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSubtle),
                            ),
                            const Spacer(),
                            const Icon(Icons.person_outline,
                                size: 13, color: AppColors.textSubtle),
                            const SizedBox(width: 4),
                            Text(
                              ann.authorName,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'alert': return AppColors.error;
      case 'event': return AppColors.info;
      case 'circular': return AppColors.accent;
      default: return AppColors.success;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'alert': return Icons.warning_amber_rounded;
      case 'event': return Icons.celebration;
      case 'circular': return Icons.mail_outline;
      default: return Icons.info_outline;
    }
  }
}
