import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../services/notification_service.dart';

/// Mark Attendance Screen – teacher selects class and marks each student.
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});
  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String _selectedClass = 'VIII-A';
  final Map<String, String> _attendance = {}; // studentId -> status

  @override
  void initState() {
    super.initState();
    for (final s in MockDataService.allStudents.where((s) => '${s.className}-${s.division}' == _selectedClass)) {
      _attendance[s.id] = 'present';
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = MockDataService.allStudents.where((s) => '${s.className}-${s.division}' == _selectedClass).toList();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Mark Attendance', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Class selector
        Container(
          height: 50, color: AppColors.surface,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), children:
            MockDataService.demoTeacher.assignedClasses.map((c) {
              final selected = c == _selectedClass;
              return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                onTap: () => setState(() { _selectedClass = c; _attendance.clear(); for (final s in MockDataService.allStudents.where((s) => '${s.className}-${s.division}' == c)) { _attendance[s.id] = 'present'; } }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: selected ? AppColors.accent : AppColors.surfaceElevated, borderRadius: BorderRadius.circular(20)),
                  child: Text(c, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: selected ? AppColors.primaryDark : AppColors.textSecondary)),
                ),
              ));
            }).toList(),
          ),
        ),
        // Student list
        Expanded(child: students.isEmpty
          ? const EmptyState(icon: Icons.people_outline, message: 'No students in this class')
          : ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: students.length,
            itemBuilder: (context, i) {
              final s = students[i];
              final status = _attendance[s.id] ?? 'present';
              return Container(
                margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))]),
                child: Row(children: [
                  CircleAvatar(radius: 18, backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                    child: Text(s.name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('Roll: ${s.rollNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
                  ])),
                  // Status toggles
                  _statusBtn('P', 'present', status, s.id, AppColors.statusPresent),
                  const SizedBox(width: 6),
                  _statusBtn('A', 'absent', status, s.id, AppColors.statusAbsent),
                  const SizedBox(width: 6),
                  _statusBtn('L', 'leave', status, s.id, AppColors.statusLeave),
                ]),
              );
            },
          ),
        ),
        // Submit button
        Container(
          padding: const EdgeInsets.all(16), color: AppColors.surface,
          child: SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final notificationService = Provider.of<NotificationService>(context, listen: false);
                
                // Trigger notification to parents of this class
                // Format topic: class_8_div_a
                final parts = _selectedClass.split('-');
                final topic = 'class_${parts[0]}_div_${parts[1]}'.toLowerCase();
                
                await notificationService.sendNotification(
                  topic: topic,
                  title: 'Attendance Updated',
                  body: 'Attendance for Class $_selectedClass has been marked for today.',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance submitted & parents notified!')));
                  Navigator.pop(context);
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

/// Teacher Announcements Screen – create/manage class announcements.
class TeacherAnnouncementsScreen extends StatelessWidget {
  const TeacherAnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final anns = MockDataService.announcements.where((a) => a.authorId == 'teacher-001').toList();
    return Scaffold(
      appBar: const GradientAppBar(title: 'My Announcements', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: anns.isEmpty
        ? const EmptyState(icon: Icons.campaign_outlined, message: 'No announcements yet.\nTap + to create one.')
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: anns.length, itemBuilder: (context, i) {
          final ann = anns[i];
          return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(ann.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                StatusChip(label: ann.type.toUpperCase(), color: AppColors.accent),
              ]),
              const SizedBox(height: 6),
              Text(ann.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          );
        }),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Create Class Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final notificationService = Provider.of<NotificationService>(context, listen: false);
            
            // Trigger class-specific notification
            // For demo purposes, we use a fixed class from the demo teacher
            final classNode = MockDataService.demoTeacher.assignedClasses.first;
            final parts = classNode.split('-');
            final topic = 'class_${parts[0]}_div_${parts[1]}'.toLowerCase();

            await notificationService.sendNotification(
              topic: topic,
              title: titleController.text.trim(),
              body: bodyController.text.trim(),
            );

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class announcement created & parents notified!')));
            }
          },
          child: const Text('Create & Notify'),
        ),
      ],
    ));
  }
}

/// Teacher Students Screen – view students in assigned classes.
class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final students = MockDataService.allStudents;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Class Students', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: students.length, itemBuilder: (context, i) {
        final s = students[i];
        return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.accent.withValues(alpha: 0.12),
              child: Text(s.name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 16))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Class ${s.fullClass} • Roll ${s.rollNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            ])),
          ]),
        );
      }),
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
    final t = MockDataService.demoTeacher;
    return Scaffold(
      appBar: const GradientAppBar(title: 'My Profile', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: Text(t.name[0], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.accent))),
            const SizedBox(height: 12),
            Text(t.name, style: const TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.w700)),
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
            _row(Icons.email, 'Email', t.email), _row(Icons.phone, 'Phone', t.phone),
            _row(Icons.book, 'Subjects', t.subjects.join(', ')),
            _row(Icons.class_, 'Classes', t.assignedClasses.join(', ')),
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
