import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';

class SubjectPortionDetailScreen extends StatelessWidget {
  final String subjectName;
  final String examName;
  final String portionText;
  final String? examDate;
  final String? examTime;

  const SubjectPortionDetailScreen({
    super.key, 
    required this.subjectName, 
    required this.examName, 
    required this.portionText,
    this.examDate,
    this.examTime,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (examDate != null && examDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(examDate!);
        formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);
      } catch (_) {
        formattedDate = examDate!;
      }
    }

    return Scaffold(
      appBar: GradientAppBar(title: subjectName, showBackButton: true),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    examName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Subject Title
                Text(
                  subjectName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Decorative Line
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Date and Time Row
                if (formattedDate.isNotEmpty || (examTime != null && examTime!.isNotEmpty))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (formattedDate.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                formattedDate,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        if (formattedDate.isNotEmpty && examTime != null && examTime!.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1),
                          ),
                        if (examTime != null && examTime!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                examTime!,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Portion Content Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'SYLLABUS PORTION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSubtle,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        portionText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Study Tip Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preparation Tip',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Focus on understanding core concepts. Practice periodic revisions.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
