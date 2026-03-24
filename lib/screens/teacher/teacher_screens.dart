import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../services/teacher_notification_service.dart';
import '../../services/auth_service.dart';


/// Mark Attendance Screen – teacher selects class and marks each student.
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});
  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Map<String, String> _attendance = {}; // studentId -> status
  bool _initialized = false;
  String? _grade;
  String? _teacherClass;
  String? _teacherDiv;

  Future<void> _initialize(BuildContext context) async {
    if (_initialized) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final teacher = authService.teacherProfile;

    if (teacher != null) {
      _teacherClass = teacher['CLASS']?.toString();
      _teacherDiv = teacher['DIV'];
      
      if (_teacherClass == '5' || _teacherClass == 'V') _grade = 'grade5';
      else if (_teacherClass == '6' || _teacherClass == 'VI') _grade = 'grade6';
      else if (_teacherClass == '7' || _teacherClass == 'VII') _grade = 'grade7';
      else if (_teacherClass == '8' || _teacherClass == 'VIII') _grade = 'grade8';
      else _grade = 'grade5';

      // Prefill attendance once we have students (we'll do this in the builder or after fetch)
    }
    
    setState(() => _initialized = true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_teacherClass == null) return const Scaffold(body: Center(child: Text('Teacher class not assigned.')));

    return Scaffold(
      appBar: const GradientAppBar(title: 'Mark Attendance', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          height: 50, color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Class: $_teacherClass | Div: $_teacherDiv', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ),
        // Student list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .doc(_grade)
                .collection('DIV_A')
                .where('CLASS', isEqualTo: _teacherClass)
                .where('DIV', isEqualTo: _teacherDiv)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const EmptyState(icon: Icons.people_outline, message: 'No students found for your class.');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final s = docs[i].data() as Map<String, dynamic>;
                  final studentId = docs[i].id;
                  final name = s['NAME'] ?? s['name'] ?? 'No Name';
                  final roll = s['rollNo'] ?? s['ROLL NO.'] ?? 'N/A';
                  
                  // Initialize if not present
                  _attendance.putIfAbsent(studentId, () => 'present');
                  
                  final status = _attendance[studentId]!;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))]),
                    child: Row(children: [
                      CircleAvatar(radius: 18, backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                        child: Text(name.isNotEmpty ? name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('Roll: $roll', style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
                      ])),
                      _statusBtn('P', 'present', status, studentId, AppColors.statusPresent),
                      const SizedBox(width: 6),
                      _statusBtn('A', 'absent', status, studentId, AppColors.statusAbsent),
                      const SizedBox(width: 6),
                      _statusBtn('L', 'leave', status, studentId, AppColors.statusLeave),
                    ]),
                  );
                },
              );
            }
          ),
        ),
        // Submit button
        Container(
          padding: const EdgeInsets.all(16), color: AppColors.surface,
          child: SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final notificationService = Provider.of<TeacherNotificationService>(context, listen: false);
                final authService = Provider.of<AuthService>(context, listen: false);
                
                try {
                  await notificationService.sendNotificationToClass(
                    teacherEmail: authService.currentUser?.email ?? '',
                    title: 'Attendance Updated',
                    message: 'Attendance for Class $_teacherClass-$_teacherDiv has been marked for today.',
                    type: 'attendance',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance submitted & parents notified!'), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Submit Attendance'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statusBtn(String label, String status, String current, String studentId, Color color) {
    final selected = current == status;
    return GestureDetector(
      onTap: () => setState(() => _attendance[studentId] = status),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : color))),
      ),
    );
  }
}

/// Teacher Students Screen – view students in assigned classes.
class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final teacher = authService.teacherProfile;

    if (teacher == null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Class Students', showBackButton: true),
        body: const Center(child: Text('Teacher profile not found.')),
      );
    }

    final teacherClass = teacher['CLASS']?.toString();
    final teacherDiv = teacher['DIV'];
    
    // Determine grade collection
    String grade = 'grade5';
    if (teacherClass == '5' || teacherClass == 'V') grade = 'grade5';
    if (teacherClass == '6' || teacherClass == 'VI') grade = 'grade6';
    if (teacherClass == '7' || teacherClass == 'VII') grade = 'grade7';
    if (teacherClass == '8' || teacherClass == 'VIII') grade = 'grade8';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Class Students', showBackButton: true),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(grade)
            .collection('DIV_A')
            .where('CLASS', isEqualTo: teacherClass)
            .where('DIV', isEqualTo: teacherDiv)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.people_outline, message: 'No students found in your assigned class.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final s = docs[i].data() as Map<String, dynamic>;
              final name = s['NAME'] ?? s['name'] ?? 'No Name';
              final grNo = s['GR NO.'] ?? s['grNo'] ?? docs[i].id;
              final roll = s['rollNo'] ?? s['ROLL NO.'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                      child: Text(name.isNotEmpty ? name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('GR: $grNo • Roll: $roll', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Teacher Quizzes Screen – manage and create quizzes.
class TeacherQuizzesScreen extends StatelessWidget {
  const TeacherQuizzesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final quizzes = MockDataService.quizzes;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Quizzes', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('Create Quiz'),
          content: const Text('In production, this opens a form to add MCQ questions with options and correct answers.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        )),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: quizzes.length, itemBuilder: (context, i) {
        final q = quizzes[i];
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.tileIconColors[5].withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.quiz, color: AppColors.tileIconColors[5], size: 22)),
            title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${q.subject} • ${q.totalQuestions} Qs', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.accent), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () {}),
            ]),
          ),
        );
      }),
    );
  }
}

/// Teacher Profile Screen.
class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final teacher = authService.teacherProfile;
    final displayName = user?.displayName ?? 'Teacher';
    final email = user?.email ?? '-';
    final assignedClass = teacher != null ? '${teacher['CLASS'] ?? 'N/A'}-${teacher['DIV'] ?? 'A'}' : 'N/A';

    return Scaffold(
      appBar: const GradientAppBar(title: 'My Profile', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: Text(displayName.isNotEmpty ? displayName[0] : 'T', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.accent))),
            const SizedBox(height: 12),
            Text(displayName, style: const TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Teacher', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 12),
            _row(Icons.email, 'Email', email), 
            _row(Icons.book, 'Subjects', 'General'),
            _row(Icons.class_, 'Assigned Class', assignedClass),
          ]),
        ),
      ])),
    );
  }
  Widget _row(IconData i, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Icon(i, size: 18, color: AppColors.accent), const SizedBox(width: 10),
      Text('$l: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right))]));
}
