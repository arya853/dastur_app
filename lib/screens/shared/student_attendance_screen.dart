import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/mock_data_service.dart';
import 'package:fl_chart/fl_chart.dart';

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
            return const Center(child: Text("Could not load attendance."));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Monthly Calendar'),
                
                // Stats summary (Monthly)
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

                // Month navigation
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
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("No data for this month", style: TextStyle(color: Colors.grey, fontSize: 13))),
                  ),

                const SizedBox(height: 16),

                // Calendar Legend
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
                
                // Attendance Overview Section (Last 30 Days)
                _buildAttendanceOverview(grade, div, grNo),
                
                const SizedBox(height: 32),
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
        bgColor = bgColor.withOpacity(0.15);
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
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
      ],
    );
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

  Widget _buildAttendanceOverview(String grade, String div, String grNo) {
    return StreamBuilder<QuerySnapshot>(
      stream: _attendanceService.streamLast30DaysAttendance(grade: grade, div: div, grNo: grNo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));

        final docs = snapshot.data!.docs;
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        final thirtyDaysAgo = startOfToday.subtract(const Duration(days: 29));

        int presentCount = 0, absentCount = 0, leaveCount = 0, holidayCount = 0;

        final holidays = MockDataService.calendarEvents
            .where((e) => e.type == 'holiday' && 
                (e.date.isAtSameMomentAs(thirtyDaysAgo) || e.date.isAfter(thirtyDaysAgo)) && 
                (e.date.isAtSameMomentAs(startOfToday) || e.date.isBefore(startOfToday)))
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet();

        final attendanceMap = <DateTime, String>{};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final status = data['status'] as String;
          attendanceMap[DateTime(date.year, date.month, date.day)] = status;
        }

        for (int i = 0; i < 30; i++) {
          final date = thirtyDaysAgo.add(Duration(days: i));
          if (date.isAfter(now)) break;
          if (date.weekday == DateTime.sunday) continue;

          if (holidays.contains(DateTime(date.year, date.month, date.day))) holidayCount++;
          else if (attendanceMap.containsKey(DateTime(date.year, date.month, date.day))) {
            final status = attendanceMap[DateTime(date.year, date.month, date.day)];
            if (status == 'present') presentCount++;
            else if (status == 'absent') absentCount++;
            else if (status == 'leave') leaveCount++;
          }
        }

        return _AttendancePieComponent(
          present: presentCount,
          absent: absentCount,
          leave: leaveCount,
          holiday: holidayCount,
        );
      },
    );
  }
}

class _AttendancePieComponent extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;
  final int holiday;

  const _AttendancePieComponent({
    required this.present,
    required this.absent,
    required this.leave,
    required this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                child: const Text('Last 30 Days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 50),
          // PREMIUM 2.5D PIE CHART
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-0.25),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Extrusion Layer (Depth)
                    Transform.translate(
                      offset: const Offset(0, 8),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 0,
                          startDegreeOffset: 270,
                          sections: _buildSections(isBottom: true),
                        ),
                      ),
                    ),
                    // Surface Layer (Top)
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 0,
                        startDegreeOffset: 270,
                        sections: _buildSections(isBottom: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Refined Legend
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _legendCard('Present', present, AppColors.statusPresent),
              _legendCard('Absent', absent, AppColors.statusAbsent),
              _legendCard('Leave', leave, AppColors.statusLeave),
              _legendCard('Holiday', holiday, AppColors.statusHoliday),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections({required bool isBottom}) {
    return [
      _section('Present', present, AppColors.statusPresent, isBottom),
      _section('Holiday', holiday, AppColors.statusHoliday, isBottom),
      _section('Absent', absent, AppColors.statusAbsent, isBottom),
      _section('Leave', leave, AppColors.statusLeave, isBottom),
    ];
  }

  PieChartSectionData _section(String title, int value, Color color, bool isBottom) {
    // Subtle, lighter depth layer
    final depthColor = Color.alphaBlend(Colors.black.withOpacity(0.12), color);
    
    // High-end glossy gradient (lighter reflections)
    final surfaceGradient = LinearGradient(
      colors: [
        Color.lerp(color, Colors.white, 0.45)!, // Lighter highlights
        Color.lerp(color, Colors.white, 0.1)!,  // Base tone
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return PieChartSectionData(
      color: isBottom ? depthColor : null,
      gradient: !isBottom ? surfaceGradient : null,
      value: value.toDouble(),
      title: '', 
      radius: 80,
      badgeWidget: !isBottom && value > 0 ? _CalloutLabel(title, color) : null,
      badgePositionPercentageOffset: 1.35,
    );
  }

  Widget _legendCard(String label, int count, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('$count', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CalloutLabel extends StatelessWidget {
  final String title;
  final Color color;

  const _CalloutLabel(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..rotateX(0.25),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color.withOpacity(0.85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 14,
            height: 2,
            decoration: BoxDecoration(
              color: color.withOpacity(0.35),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
