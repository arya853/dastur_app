import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/exam_syllabus_service.dart';
import '../../core/utils/string_utils.dart';

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
      padding: const EdgeInsets.all(16),
      itemCount: subjectNames.length,
      itemBuilder: (context, index) {
        final subject = subjectNames[index];
        final portion = subjects[subject].toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tileIconColors[index % AppColors.tileIconColors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.book_outlined,
                color: AppColors.tileIconColors[index % AppColors.tileIconColors.length],
                size: 20,
              ),
            ),
            title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: const Text("Tap to view portion", style: TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      portion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
