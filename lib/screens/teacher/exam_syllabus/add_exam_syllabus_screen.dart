import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/exam_syllabus_service.dart';

class AddExamSyllabusScreen extends StatefulWidget {
  final String grade;
  final String div;
  final Map<String, dynamic>? initialData;

  const AddExamSyllabusScreen({super.key, required this.grade, required this.div, this.initialData});

  @override
  State<AddExamSyllabusScreen> createState() => _AddExamSyllabusScreenState();
}

class _AddExamSyllabusScreenState extends State<AddExamSyllabusScreen> {
  final ExamSyllabusService _service = ExamSyllabusService();
  final TextEditingController _examNameController = TextEditingController();
  final List<TextEditingController> _subjectControllers = [];
  final List<TextEditingController> _portionControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _examNameController.text = widget.initialData!['examName'] ?? '';
      final subjectsMap = widget.initialData!['subjects'] as Map<String, dynamic>? ?? {};
      subjectsMap.forEach((key, value) {
        _subjectControllers.add(TextEditingController(text: key));
        _portionControllers.add(TextEditingController(text: value.toString()));
      });
    } else {
      // Start with one empty slot
      _addSlot();
    }
  }

  void _addSlot() {
    setState(() {
      _subjectControllers.add(TextEditingController());
      _portionControllers.add(TextEditingController());
    });
  }

  void _removeSlot(int index) {
    setState(() {
      _subjectControllers[index].dispose();
      _portionControllers[index].dispose();
      _subjectControllers.removeAt(index);
      _portionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _examNameController.dispose();
    for (var c in _subjectControllers) {
      c.dispose();
    }
    for (var c in _portionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final examName = _examNameController.text.trim();
    if (examName.isEmpty) {
      _showError("Please enter an exam name.");
      return;
    }

    final Map<String, String> subjectsData = {};
    for (int i = 0; i < _subjectControllers.length; i++) {
      final s = _subjectControllers[i].text.trim();
      final p = _portionControllers[i].text.trim();
      if (s.isNotEmpty && p.isNotEmpty) {
        subjectsData[s] = p;
      }
    }

    if (subjectsData.isEmpty) {
      _showError("Please add at least one subject and its portion.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.saveExamSyllabus(
        grade: widget.grade,
        div: widget.div,
        examName: examName,
        subjects: subjectsData,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError("Failed to save syllabus: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: widget.initialData != null ? 'Edit Exam Portions' : 'Add Exam Portions',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Examination Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _examNameController,
                    decoration: InputDecoration(
                      hintText: "e.g., First Unit Test",
                      fillColor: AppColors.surface,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    enabled: widget.initialData == null, // Name shouldn't change for unique ID consistency
                  ),
                  const SizedBox(height: 24),
                  const Text("Subjects & Portions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subjectControllers.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _subjectControllers[index],
                                    decoration: InputDecoration(
                                      hintText: "Subject Name (e.g., Maths)",
                                      labelText: "Subject",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                if (_subjectControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                                    onPressed: () => _removeSlot(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _portionControllers[index],
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Enter the portion / syllabus for this exam...",
                                labelText: "Portion Details",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Add Another Subject"),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg),),
                      ),
                      child: const Text("SAVE EXAM SYLLABUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
