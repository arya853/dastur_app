import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/auth_service.dart';
import '../../../services/exam_syllabus_service.dart';
import '../../../core/utils/string_utils.dart';
import 'add_exam_syllabus_screen.dart';

class ManageExamSyllabusScreen extends StatefulWidget {
  const ManageExamSyllabusScreen({super.key});

  @override
  State<ManageExamSyllabusScreen> createState() => _ManageExamSyllabusScreenState();
}

class _ManageExamSyllabusScreenState extends State<ManageExamSyllabusScreen> {
  final ExamSyllabusService _service = ExamSyllabusService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final teacherProfile = authService.teacherProfile;
    
    if (teacherProfile == null) {
      return const Scaffold(body: Center(child: Text("Teacher profile not found.")));
    }

    final String grade = StringUtils.normalizeGrade((teacherProfile['grade'] ?? teacherProfile['gradeName'] ?? 'grade5').toString());
    final String div = StringUtils.normalizeDivision((teacherProfile['DIV'] ?? 'A').toString());

    return Scaffold(
      appBar: const GradientAppBar(title: 'Exam Syllabus', showBackButton: true),
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
                  Icon(Icons.menu_book, size: 64, color: AppColors.textSubtle.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("No exam syllabus added yet.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _navigateToAdd(context, grade, div),
                    child: const Text("Add First Exam"),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final examName = data['examName'] ?? 'Unnamed Exam';
              final subjectsCount = (data['subjects'] as Map?)?.length ?? 0;
              final docId = docs[index].id;

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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(examName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('$subjectsCount subjects defined', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                        onPressed: () => _navigateToEdit(context, grade, div, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => _confirmDelete(context, docId, examName),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context, grade, div),
        label: const Text("Add Exam", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToAdd(BuildContext context, String grade, String div) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExamSyllabusScreen(grade: grade, div: div),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, String grade, String div, Map<String, dynamic> existingData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExamSyllabusScreen(
          grade: grade,
          div: div,
          initialData: existingData,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String examName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exam Syllabus?"),
        content: Text("Are you sure you want to remove the portions for '$examName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _service.deleteExamSyllabus(docId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
