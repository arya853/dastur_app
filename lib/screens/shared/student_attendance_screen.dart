import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';

/// Attendance Calendar Screen – live visual calendar from Firestore.
class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  late DateTime _selectedMonth;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.studentProfile;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Student profile not found.")));
    }

    final String grade = (user['grade'] ?? user['gradeName'] ?? 'grade5').toString();
    final String div = (user['DIV'] ?? 'A').toString();
    final String grNo = (user['GR NO.'] ?? user['grNo'] ?? '').toString();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Attendance', showBackButton: true),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _attendanceService.streamMonthAttendance(
          grade: grade,
          div: div,
          grNo: grNo,
          month: _selectedMonth,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Could not load attendance. Check your connection."));
          }

          final docs = snapshot.data?.docs ?? [];
          final attendanceMap = <int, String>{};
          int present = 0, absent = 0, leave = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final status = data['status'] as String;
            attendanceMap[date.day] = status;

            if (status == 'present') present++;
            else if (status == 'absent') absent++;
            else if (status == 'leave') leave++;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Stats summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Present', '$present', AppColors.statusPresent),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                      _statItem('Absent', '$absent', AppColors.statusAbsent),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                      _statItem('Leave', '$leave', AppColors.statusLeave),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                      _statItem('Total', '${present + absent + leave}', AppColors.accent),
                    ],
                  ),
                ),
                // Month nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1)),
                      ),
                      Text(_monthYear(_selectedMonth), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)),
                      ),
                    ],
                  ),
                ),
                // Day headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)))))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildGrid(attendanceMap),
                ),
                if (docs.isEmpty) 
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No attendance data for this month", style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(height: 16),
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _legend(AppColors.statusPresent, 'Present'),
                      _legend(AppColors.statusAbsent, 'Absent'),
                      _legend(AppColors.statusLeave, 'Leave'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(Map<int, String> attendanceMap) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final cells = <Widget>[];

    // Padding for first week
    for (int i = 1; i < firstDay.weekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final status = attendanceMap[day];

      Color? bgColor;
      Color? borderColor;
      if (status == 'present') {
        bgColor = AppColors.statusPresent;
      } else if (status == 'absent') {
        bgColor = AppColors.statusAbsent;
      } else if (status == 'leave') {
        bgColor = AppColors.statusLeave;
      }

      if (bgColor != null) {
        borderColor = bgColor.withOpacity(0.5);
        bgColor = bgColor.withOpacity(0.2);
      }

      cells.add(Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) 
                  ? AppColors.error 
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: cells,
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
    ]);
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(3), border: Border.all(color: color, width: 1.5))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  String _monthYear(DateTime d) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[d.month - 1]} ${d.year}';
  }
}
