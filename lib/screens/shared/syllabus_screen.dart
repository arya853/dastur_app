import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/subject.dart';

/// Syllabus Screen – expandable list of subjects and chapters.
class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  late List<Subject> _subjects;

  @override
  void initState() {
    super.initState();
    // Load from mock data service
    _subjects = MockDataService.subjects;
  }

  void _toggleChapter(int subjectIndex, int chapterIndex) {
    setState(() {
      final subject = _subjects[subjectIndex];
      final chapter = subject.chapters[chapterIndex];
      
      final updatedChapter = chapter.copyWith(completed: !chapter.completed);
      subject.chapters[chapterIndex] = updatedChapter;
    });
    
    _showFeedback('Syllabus progress updated');
  }

  void _showFeedback(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bool isTeacher = authService.currentUser?.role == 'teacher';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Syllabus / Portions', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        itemBuilder: (context, subjectIndex) {
          final subject = _subjects[subjectIndex];
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
                    color: AppColors.tileIconColors[subjectIndex % AppColors.tileIconColors.length]
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.book_outlined,
                      color: AppColors.tileIconColors[subjectIndex % AppColors.tileIconColors.length],
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
                children: List.generate(subject.chapters.length, (chapterIndex) {
                  final chapter = subject.chapters[chapterIndex];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: isTeacher ? () => _toggleChapter(subjectIndex, chapterIndex) : null,
                    leading: isTeacher 
                      ? Checkbox(
                          value: chapter.completed,
                          activeColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (_) => _toggleChapter(subjectIndex, chapterIndex),
                        )
                      : Icon(
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
                        fontWeight: chapter.completed ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                    trailing: isTeacher ? const Icon(Icons.edit_outlined, size: 14, color: AppColors.textSubtle) : null,
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
