import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Announcements Screen - clean feed layout showing all announcements.
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = MockDataService.announcements;

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Announcements',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final ann = announcements[index];
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
                        Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textSubtle),
                        const SizedBox(width: 4),
                        Text(
                          '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSubtle),
                        ),
                        const Spacer(),
                        Icon(Icons.person_outline,
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
