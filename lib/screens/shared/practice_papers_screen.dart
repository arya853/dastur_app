import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Practice Papers Screen – downloadable papers by subject.
class PracticePapersScreen extends StatelessWidget {
  const PracticePapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final papers = MockDataService.practicePapers;
    // Group by subject
    final grouped = <String, List>{};
    for (final paper in papers) {
      grouped.putIfAbsent(paper.subject, () => []).add(paper);
    }

    return Scaffold(
      appBar: const GradientAppBar(title: 'Practice Papers', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
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
      ),
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
