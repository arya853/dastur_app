import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../services/notification_service.dart';

/// Admin Manage Students Screen.
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final students = MockDataService.allStudents.where((s) => 
      s.grNo.contains(_searchQuery) || 
      s.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Students', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(onPressed: () => _showFormDialog(context, 'Add Student'), child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name or GR Number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16), 
              itemCount: students.length, 
              itemBuilder: (context, i) {
                final s = students[i];
                return _managementCard(
                  avatar: s.name[0], title: s.name, subtitle: 'GR: ${s.grNo} • Class ${s.fullClass}',
                  onEdit: () => _showFormDialog(context, 'Edit Student'),
                  onDelete: () => _confirmDelete(context, s.name),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin Manage Teachers Screen.
class AdminTeachersScreen extends StatelessWidget {
  const AdminTeachersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Teachers', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(onPressed: () => _showFormDialog(context, 'Add Teacher'), child: const Icon(Icons.add)),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: MockDataService.allTeachers.length, itemBuilder: (context, i) {
        final t = MockDataService.allTeachers[i];
        return _managementCard(
          avatar: t.name[0], title: t.name, subtitle: '${t.subjects.join(", ")} • ${t.assignedClasses.join(", ")}',
          onEdit: () => _showFormDialog(context, 'Edit Teacher'),
          onDelete: () => _confirmDelete(context, t.name),
        );
      }),
    );
  }
}

/// Admin Manage Parents Screen.
class AdminParentsScreen extends StatelessWidget {
  const AdminParentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Parents', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(onPressed: () => _showFormDialog(context, 'Add Parent'), child: const Icon(Icons.add)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _managementCard(
          avatar: MockDataService.demoParent.name[0], title: MockDataService.demoParent.name,
          subtitle: 'Child: ${MockDataService.demoStudent.name}',
          onEdit: () => _showFormDialog(context, 'Edit Parent'), onDelete: () => _confirmDelete(context, MockDataService.demoParent.name),
        ),
      ]),
    );
  }
}

/// Admin Announcements Screen – school-wide CRUD.
class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Announcements', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnnouncementDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: MockDataService.announcements.length, itemBuilder: (context, i) {
        final a = MockDataService.announcements[i];
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('${a.date.day}/${a.date.month}/${a.date.year} • ${a.type}', style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
            ])),
            IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.accent), onPressed: () => _showFormDialog(context, 'Edit Announcement')),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () => _confirmDelete(context, a.title)),
          ]),
        );
      }),
    );
  }
}

/// Admin Calendar Events Screen.
class AdminCalendarScreen extends StatelessWidget {
  const AdminCalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Calendar', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(onPressed: () => _showFormDialog(context, 'Add Event'), child: const Icon(Icons.add)),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: MockDataService.calendarEvents.length, itemBuilder: (context, i) {
        final e = MockDataService.calendarEvents[i];
        return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${e.date.day}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.info)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(e.type.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
            ])),
            IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.accent), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () {}),
          ]),
        );
      }),
    );
  }
}

/// Admin Manage Timetable.
class AdminTimetableScreen extends StatelessWidget {
  const AdminTimetableScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Timetable', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.schedule, size: 64, color: AppColors.accent),
        const SizedBox(height: 16),
        const Text('Timetable Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Create and edit timetables for all classes.\nSelect a class to begin.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/timetable'), child: const Text('View Current Timetable')),
      ])),
    );
  }
}

/// Admin Manage Fees.
class AdminFeesScreen extends StatelessWidget {
  const AdminFeesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Fees', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // Overview stats
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _stat('Total Students', '${MockDataService.allStudents.length}', AppColors.accent),
            Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
            _stat('Collected', '₹ 2,40,000', AppColors.success),
            Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
            _stat('Pending', '₹ 1,20,000', AppColors.warning),
          ]),
        ),
        const SizedBox(height: 16),
        // Student fee list
        ...MockDataService.allStudents.take(4).map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.accent.withValues(alpha: 0.12),
              child: Text(s.name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Class ${s.fullClass}', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            ])),
            const StatusChip(label: 'PAID', color: AppColors.success),
          ]),
        )),
      ])),
    );
  }
  Widget _stat(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 14)),
    const SizedBox(height: 2),
    Text(l, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 10)),
  ]);
}

/// Admin Exam Timetable.
class AdminExamTimetableScreen extends StatelessWidget {
  const AdminExamTimetableScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GradientAppBar(title: 'Manage Exam Schedule', showBackButton: true),
    backgroundColor: AppColors.background,
    floatingActionButton: FloatingActionButton(onPressed: () => _showFormDialog(context, 'Add Exam'), child: const Icon(Icons.add)),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.event_note, size: 64, color: AppColors.warning),
      const SizedBox(height: 16),
      const Text('Exam Schedule Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/exam-timetable'), child: const Text('View Exam Schedule')),
    ])),
  );
}

/// Admin Reports Screen.
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GradientAppBar(title: 'Reports & Analytics', showBackButton: true),
    backgroundColor: AppColors.background,
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _reportCard(Icons.fact_check, 'Attendance Report', 'View class-wise attendance summary', AppColors.tileIconColors[8]),
      _reportCard(Icons.account_balance_wallet, 'Fee Collection Report', 'Track fee payments and pending amounts', AppColors.tileIconColors[7]),
      _reportCard(Icons.school, 'Student Performance', 'Quiz scores and academic progress', AppColors.tileIconColors[5]),
      _reportCard(Icons.bar_chart, 'Class Analytics', 'Comparative analysis across classes', AppColors.tileIconColors[0]),
    ]),
  );
  Widget _reportCard(IconData icon, String title, String subtitle, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtle),
    ]),
  );
}

/// Admin Settings Screen.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GradientAppBar(title: 'Settings', showBackButton: true),
    backgroundColor: AppColors.background,
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _settingsTile(Icons.school, 'School Information', 'Name, address, contact'),
      _settingsTile(Icons.calendar_today, 'Academic Year', 'Current: ${AppConstants.academicYear}'),
      _settingsTile(Icons.lock, 'Change Password', 'Update admin credentials'),
      _settingsTile(Icons.notifications, 'Notification Settings', 'Configure push notifications'),
      _settingsTile(Icons.info, 'App Version', AppConstants.appVersion),
    ]),
  );
  Widget _settingsTile(IconData icon, String title, String subtitle) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
    child: ListTile(contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtle),
    ),
  );
}

// ── Shared Helper Widgets ──

Widget _managementCard({required String avatar, required String title, required String subtitle, required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Row(children: [
      CircleAvatar(radius: 20, backgroundColor: AppColors.accent.withValues(alpha: 0.12),
        child: Text(avatar, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 16))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
      ])),
      IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.accent), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: onDelete),
    ]),
  );
}

void _showAnnouncementDialog(BuildContext context) {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create School Announcement'),
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
            
            // Trigger school-wide notification
            await notificationService.sendNotification(
              topic: 'school_announcements',
              title: titleController.text.trim(),
              body: bodyController.text.trim(),
            );

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement created & notifications sent!')));
            }
          },
          child: const Text('Create & Notify'),
        ),
      ],
    ),
  );
}

void _showFormDialog(BuildContext context, String title) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: Text(title), content: Text('In production, this shows the full $title form with all required fields.'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ));
}

void _confirmDelete(BuildContext context, String name) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text('Confirm Delete'),
    content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      TextButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name deleted'))); },
        child: const Text('Delete', style: TextStyle(color: AppColors.error))),
    ],
  ));
}
