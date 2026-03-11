import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Syllabus Screen – expandable list of subjects and chapters.
class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = MockDataService.subjects;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Syllabus / Portions', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.tileIconColors[index % AppColors.tileIconColors.length]
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.book_outlined,
                      color: AppColors.tileIconColors[index % AppColors.tileIconColors.length],
                      size: 22),
                ),
                title: Text(subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Row(
                  children: [
                    Text(
                      '${subject.completedCount}/${subject.chapters.length} completed',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: subject.completionPercentage,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            subject.completionPercentage >= 1.0
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ],
                ),
                children: subject.chapters.map((chapter) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(
                      chapter.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: chapter.completed ? AppColors.success : AppColors.textSubtle,
                      size: 20,
                    ),
                    title: Text(
                      chapter.name,
                      style: TextStyle(
                        fontSize: 13,
                        decoration: chapter.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: chapter.completed
                            ? AppColors.textSubtle
                            : AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
