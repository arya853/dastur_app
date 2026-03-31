import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/exam_syllabus_service.dart';
import '../../core/utils/string_utils.dart';
import 'subject_portion_detail_screen.dart';

class ExamSyllabusViewScreen extends StatefulWidget {
  const ExamSyllabusViewScreen({super.key});

  @override
  State<ExamSyllabusViewScreen> createState() => _ExamSyllabusViewScreenState();
}

class _ExamSyllabusViewScreenState extends State<ExamSyllabusViewScreen> {
  final ExamSyllabusService _service = ExamSyllabusService();
  String? _selectedExamId;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProfile = authService.currentUser?.role == 'teacher' 
        ? authService.teacherProfile 
        : authService.studentProfile;
    
    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text("Profile data not found.")));
    }

    final String grade = StringUtils.normalizeGrade((userProfile['grade'] ?? userProfile['gradeName'] ?? userProfile['CLASS'] ?? 'grade5').toString());
    final String div = StringUtils.normalizeDivision((userProfile['DIV'] ?? userProfile['division'] ?? 'A').toString());

    return Scaffold(
      appBar: const GradientAppBar(title: 'Exam Porions / Syllabus', showBackButton: true),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.streamExamsForClass(grade, div),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: AppColors.textSubtle.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("No exam portions have been added yet.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text("Please check back later.", style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          
          return Column(
            children: [
              // Exam Selection Tab Bar
              Container(
                height: 60,
                color: AppColors.surface,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final examName = data['examName'] ?? 'Exam';
                    final isSelected = _selectedExamId == docs[index].id || (_selectedExamId == null && index == 0);
                    
                    if (_selectedExamId == null && index == 0) {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         if(mounted) setState(() => _selectedExamId = docs[index].id);
                       });
                    }

                    return GestureDetector(
                      onTap: () => setState(() => _selectedExamId = docs[index].id),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            examName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const Divider(height: 1),

              // Portion Details
              Expanded(
                child: _selectedExamId == null 
                  ? const SizedBox()
                  : _buildPortionList(docs.firstWhere((d) => d.id == _selectedExamId)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPortionList(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final subjects = data['subjects'] as Map<String, dynamic>? ?? {};
    final subjectNames = subjects.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: subjectNames.length,
      itemBuilder: (context, index) {
        final subject = subjectNames[index];
        final subjectData = subjects[subject];
        
        final String portion = (subjectData is Map ? subjectData['portion'] : subjectData).toString();
        final String dateStr = (subjectData is Map ? (subjectData['date'] ?? '') : '').toString();
        final String timeStr = (subjectData is Map ? (subjectData['time'] ?? '') : '').toString();
        
        final examName = data['examName'] ?? 'Exam';

        DateTime? parsedDate;
        try {
          if (dateStr.isNotEmpty) {
            parsedDate = DateTime.parse(dateStr);
          }
        } catch (_) {}

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectPortionDetailScreen(
                  subjectName: subject,
                  examName: examName,
                  portionText: portion,
                  examDate: dateStr,
                  examTime: timeStr,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Premium Left Banner (Blue Gradient) - showing Date if available
                Container(
                  width: 80,
                  height: 125,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: parsedDate != null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            parsedDate.day.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26),
                          ),
                          Text(
                            DateFormat('MMM').format(parsedDate).toUpperCase(),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          subject.isNotEmpty ? subject[0].toUpperCase() : 'B',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Exam Name Tag (Pill)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            examName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accentDark,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Time indicator - matching the reference image
                        if (timeStr.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 15, color: AppColors.textSubtle),
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.description_outlined, size: 14, color: AppColors.textSubtle),
                              SizedBox(width: 4),
                              Text(
                                'View Detailed Portion',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSubtle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Icon indicator
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
