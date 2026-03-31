import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../models/announcement.dart';
import '../../services/admin_announcement_service.dart';

import '../../services/student_service.dart';

/// Admin Manage Students Screen.
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic>? _allStudents;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await StudentService().fetchAllStudents();
      if (mounted) {
        setState(() {
          _allStudents = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: GradientAppBar(title: 'Manage Students', showBackButton: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 1. Filter students based on search query
    final students = (_allStudents ?? []).where((s) {
      final name = s.name.toLowerCase();
      final grNo = s.grNo.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || grNo.contains(query);
    }).toList();

    // 2. Grouping Logic (only for non-search views)
    final Map<String, List<dynamic>> groupedStudents = {};
    if (_searchQuery.isEmpty) {
      for (var s in (_allStudents ?? [])) {
        final key = 'Class ${s.fullClass}';
        if (!groupedStudents.containsKey(key)) {
          groupedStudents[key] = [];
        }
        groupedStudents[key]!.add(s);
      }
    }

    // Sort keys alphabetically (Class 5 A, then 5 B, etc)
    final sortedKeys = groupedStudents.keys.toList()..sort();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Students', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, 'Add Student'), 
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Name or GR Number...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: students.isEmpty && _searchQuery.isNotEmpty
                ? const Center(child: Text('No students found matching your search.'))
                : _searchQuery.isNotEmpty 
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16), 
                      itemCount: students.length, 
                      itemBuilder: (context, i) {
                        final s = students[i];
                        return _managementCard(
                          avatar: s.name[0], title: s.name, subtitle: 'GR: ${s.grNo} • Class ${s.fullClass}',
                          onEdit: () => _showFormDialog(context, 'Edit Student'),
                          onDelete: () => _confirmDelete(context, s.name, () {
                            debugPrint('Deleting student ${s.name}');
                          }),
                        );
                      }
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final classKey = sortedKeys[index];
                        final classStudents = groupedStudents[classKey]!;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border.withOpacity(0.5)),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                child: const Icon(Icons.groups, size: 20, color: AppColors.primary),
                              ),
                              title: Text(classKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                              subtitle: Text('${classStudents.length} Students', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
                              childrenPadding: const EdgeInsets.all(12),
                              children: classStudents.map((s) => _managementCard(
                                avatar: s.name[0], title: s.name, subtitle: 'GR: ${s.grNo}',
                                onEdit: () => _showFormDialog(context, 'Edit Student'),
                                onDelete: () => _confirmDelete(context, s.name, () {
                                  debugPrint('Deleting student ${s.name}');
                                }),
                              )).toList(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.person_off_outlined, message: 'No teachers found.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'No Name';
              final email = data['email'] ?? docs[i].id;
              final className = data['CLASS']?.toString() ?? 'N/A';
              final div = data['DIV'] ?? 'N/A';

              return _managementCard(
                avatar: name.isNotEmpty ? name[0] : 'T',
                title: name,
                subtitle: 'Email: $email\nClass: $className | Div: $div',
                onEdit: () => _showAddTeacherDialog(context, teacherData: data, docId: docs[i].id),
                onDelete: () => _confirmDelete(context, name, () {
                  FirebaseFirestore.instance.collection('teachers').doc(docs[i].id).delete();
                }),
              );
            },
          );
        },
      ),
    );
  }
}

/// Admin Manage Parents Screen (DELETED as per previous request)

/// Admin Announcements Screen – school-wide CRUD.
class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Announcements', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin-create-announcement'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('announcements').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.campaign_outlined, message: 'No announcements found.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16), 
            itemCount: docs.length, 
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final a = Announcement.fromMap(data, docs[i].id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10), 
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: a.isActive ? AppColors.surface : Colors.grey.shade200, 
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: a.isActive ? Colors.transparent : Colors.grey.shade400)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text(
                            a.title, 
                            style: TextStyle(
                              fontWeight: FontWeight.w600, 
                              fontSize: 14,
                              decoration: a.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                              color: a.isActive ? AppColors.textPrimary : Colors.grey.shade600,
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${a.date.day}/${a.date.month}/${a.date.year} • ${a.type.toUpperCase()} • To: ${a.targetRole.toUpperCase()}${a.targetClass != null ? ' (Grade ${a.targetClass})' : ''}', 
                            style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)
                          ),
                        ]
                      )
                    ),
                    Switch(
                      value: a.isActive,
                      activeColor: AppColors.accent,
                      onChanged: (val) {
                        AdminAnnouncementService().toggleActive(a.id, !val);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: AppColors.error), 
                      onPressed: () => _confirmDelete(context, a.title, () {
                        AdminAnnouncementService().deleteAnnouncement(a.id);
                      })
                    ),
                  ]
                ),
              );
            }
          );
        }
      ),
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
          onPressed: () {
            // TODO: Link to a centralized Announcement Service
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement created (Notifications logic TBD)')));
          },
          child: const Text('Create'),
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

void _showAddTeacherDialog(BuildContext context, {Map<String, dynamic>? teacherData, String? docId}) {
  final nameController = TextEditingController(text: teacherData?['name']);
  final emailController = TextEditingController(text: teacherData?['email'] ?? docId);
  String selectedClass = teacherData?['CLASS']?.toString() ?? '5';
  String selectedDiv = teacherData?['DIV'] ?? 'A';
  bool isEdit = teacherData != null;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(isEdit ? 'Edit Teacher' : 'Add New Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Teacher Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                enabled: !isEdit,
              ),
              const SizedBox(height: 16),
              const Text('Assigned Class:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedClass,
                items: ['5', '6', '7', '8'].map((c) => DropdownMenuItem(value: c, child: Text('Grade $c'))).toList(),
                onChanged: (val) => setDialogState(() => selectedClass = val!),
              ),
              const SizedBox(height: 8),
              const Text('Division:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedDiv,
                items: ['A', 'B'].map((d) => DropdownMenuItem(value: d, child: Text('Division $d'))).toList(),
                onChanged: (val) => setDialogState(() => selectedDiv = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                return;
              }

              final email = emailController.text.trim().toLowerCase();
              final data = {
                'name': nameController.text.trim(),
                'email': email,
                'CLASS': selectedClass, // Save as String to match student data format
                'DIV': selectedDiv,
              };

              try {
                if (isEdit) {
                  await FirebaseFirestore.instance.collection('teachers').doc(docId).update(data);
                } else {
                  // Check if teacher already exists
                  final existing = await FirebaseFirestore.instance.collection('teachers').doc(email).get();
                  if (existing.exists) {
                    throw "Teacher with this email already exists.";
                  }
                  await FirebaseFirestore.instance.collection('teachers').doc(email).set(data);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Teacher updated' : 'Teacher added successfully')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    ),
  );
}

void _confirmDelete(BuildContext context, String name, VoidCallback onDelete) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text('Confirm Delete'),
    content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      TextButton(onPressed: () { 
        onDelete();
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name deleted'))); 
      },
        child: const Text('Delete', style: TextStyle(color: AppColors.error))),
    ],
  ));
}
