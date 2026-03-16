import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Announcement Detail',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
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
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(
                        label: announcement.type.toUpperCase(),
                        color: _typeColor(announcement.type),
                      ),
                      Text(
                        '${announcement.date.day}/${announcement.date.month}/${announcement.date.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Posted by ${announcement.authorName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Body Section
            const Text(
              'Detail Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Text(
                announcement.body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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
}
