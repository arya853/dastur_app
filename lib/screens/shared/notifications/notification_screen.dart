import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/notification.dart';
import '../../../../models/announcement.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NotificationController>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final studentData = authService.studentProfile;
    final userRole = authService.currentUser?.role ?? 'parent';
    
    // For parents/students, we need student data to fetch personal notifications
    if (userRole != 'teacher' && studentData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text("You need to be logged in to view notifications.")),
      );
    }
    
    String grade = 'grade5';
    String grNo = 'teacher'; // Unique identifier for teacher vs personal notifications

    if (studentData != null) {
      final className = (studentData['CLASS'] ?? studentData['className'] ?? 'Unknown').toString();
      if (className == '5' || className == 'V') grade = 'grade5';
      if (className == '6' || className == 'VI') grade = 'grade6';
      if (className == '7' || className == 'VII') grade = 'grade7';
      if (className == '8' || className == 'VIII') grade = 'grade8';
      grNo = studentData['GR NO.'] ?? studentData['grNo'] ?? (authService.currentUser?.email ?? '').split('@').first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          StreamBuilder<int>(
            stream: controller.getUnreadCountStream(grade, grNo),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: () => controller.markAllAsRead(grade, grNo),
                  child: const Text('Mark all as read', style: TextStyle(color: AppColors.primary)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: userRole == 'teacher' 
            ? _getTeacherAnnouncementsStream(authService)
            : controller.getNotificationsStream(grade, grNo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              return NotificationTile(
                notification: notifications[index],
                grade: grade,
                grNo: grNo,
                controller: controller,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Maps global announcements to the AppNotification model for teachers to see in their feed.
  Stream<List<AppNotification>> _getTeacherAnnouncementsStream(AuthService auth) {
    return FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final List<AppNotification> items = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String role = data['targetRole'] ?? 'all';
        
        // Basic filtering for teachers (only show 'all' or 'teachers')
        if (role == 'all' || role == 'teachers' || role == 'teacher') {
          final ann = Announcement.fromMap(data, doc.id);
          items.add(AppNotification(
            id: ann.id,
            title: ann.title,
            message: ann.body,
            type: 'announcement',
            senderRole: 'admin',
            senderEmail: ann.authorName,
            isRead: true, // We don't track per-user read status for global announcements yet
            timestamp: ann.date,
          ));
        }
      }
      return items;
    });
  }
}
