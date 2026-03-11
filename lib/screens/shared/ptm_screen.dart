import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// PTM Screen – shows upcoming Parent-Teacher Meeting schedules.
class PtmScreen extends StatelessWidget {
  const PtmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ptms = MockDataService.ptmSchedule;

    return Scaffold(
      appBar: const GradientAppBar(title: 'PTM Schedule', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ptms.length,
        itemBuilder: (context, index) {
          final ptm = ptms[index];
          final isUpcoming = ptm.date.isAfter(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: isUpcoming
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? AppColors.accent.withValues(alpha: 0.12)
                              : AppColors.textSubtle.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: isUpcoming ? AppColors.accent : AppColors.textSubtle,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PTM – Class ${ptm.classId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ptm.date.day}/${ptm.date.month}/${ptm.date.year}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isUpcoming ? AppColors.accent : AppColors.textSubtle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        label: isUpcoming ? 'UPCOMING' : 'PAST',
                        color: isUpcoming ? AppColors.success : AppColors.textSubtle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Teacher info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Class Teacher: ${ptm.teacherName}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  // Instructions
                  Text(
                    ptm.instructions,
                    style: const TextStyle(
                      fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
