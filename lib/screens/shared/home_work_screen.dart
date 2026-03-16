import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../models/quiz.dart';

/// Consolidated Home Work Screen
/// Shows Worksheets and Quizzes with a side-by-side toggle.
class HomeWorkScreen extends StatefulWidget {
  const HomeWorkScreen({super.key});

  @override
  State<HomeWorkScreen> createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen> {
  bool _showWorksheets = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Home Work', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Side-by-side Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: 'Worksheets',
                      isSelected: _showWorksheets,
                      onTap: () => setState(() => _showWorksheets = true),
                    ),
                  ),
                  Expanded(
                    child: _buildToggleButton(
                      label: 'Quizzes',
                      isSelected: !_showWorksheets,
                      onTap: () => setState(() => _showWorksheets = false),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content Area
          Expanded(
            child: _showWorksheets ? _buildWorksheetsList() : _buildQuizzesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWorksheetsList() {
    final papers = MockDataService.practicePapers;
    final grouped = <String, List>{};
    for (final paper in papers) {
      grouped.putIfAbsent(paper.subject, () => []).add(paper);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: entry.key),
            ...entry.value.map((paper) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description_outlined,
                          color: AppColors.info, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(paper.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          StatusChip(
                            label: paper.examType.replaceAll('_', ' ').toUpperCase(),
                            color: _examTypeColor(paper.examType),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: AppColors.accent),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading ${paper.title}...')),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuizzesList() {
    final quizzes = MockDataService.quizzes;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tileIconColors[5].withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.quiz_rounded,
                  color: AppColors.tileIconColors[5], size: 24),
            ),
            title: Text(quiz.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${quiz.subject} • ${quiz.totalQuestions} Questions',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Start',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark)),
            ),
            onTap: () => Navigator.pushNamed(context, '/quiz-play', arguments: quiz),
          ),
        );
      },
    );
  }

  Color _examTypeColor(String type) {
    switch (type) {
      case 'unit_test': return AppColors.info;
      case 'midterm': return AppColors.warning;
      case 'final': return AppColors.error;
      default: return AppColors.success;
    }
  }
}
