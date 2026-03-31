import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import 'package:fl_chart/fl_chart.dart';

/// Professional Student Attendance Screen
/// Features a card-based layout, real-time month sync, and 30-day analytics.
class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  // --- REDESIGN COLOR PALETTE ---
  static const Color colorPresent = Color(0xFF1A7D40);
  static const Color colorAbsent = Color(0xFFCC2E2E);
  static const Color colorLeave = Color(0xFFB07A10);
  static const Color colorTotal = Color(0xFF1A2540);
  static const Color colorRate = Color(0xFF1A5FC4);
  static const Color colorDarkNavy = Color(0xFF1A2540);
  static const Color colorBorder = Color(0xFFDDE3EE);
  static const Color colorGreyText = Color(0xFF8898AA);
  static const Color colorMutedBlue = Color(0xFF7A8FB0);
  static const Color colorBackground = Color(0xFFF8F9FE);

  late DateTime _selectedMonth;
  final AttendanceService _attendanceService = AttendanceService();
  DateTime? _lastFetched;

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

    // Student Subtitle Info
    final String studentClass = (user['className'] ?? user['CLASS'] ?? '5').toString();
    final String studentDiv = (user['division'] ?? user['DIV'] ?? 'A').toString();
    final String subtitle = "Class $studentClass — Division $studentDiv";

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: _buildAppBar(subtitle),
      body: StreamBuilder<QuerySnapshot>(
        // Single stream that covers the selected month AND last 30 days
        stream: _getUnifiedStream(grade, div, grNo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          _lastFetched = DateTime.now();
          final docs = snapshot.data?.docs ?? [];
          
          // Build Attendance Map for O(1) Access: "yyyy-MM-dd" -> status
          final Map<String, String> attendanceMap = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final status = (data['status'] as String? ?? 'present').toLowerCase();
            attendanceMap[DateFormat('yyyy-MM-dd').format(date)] = status;
          }

          // Calculate Month-Specific Stats
          int mPresent = 0, mAbsent = 0, mLeave = 0;
          final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

          for (var dateStr in attendanceMap.keys) {
            final date = DateFormat('yyyy-MM-dd').parse(dateStr);
            if (date.isAfter(monthStart.subtract(const Duration(seconds: 1))) && 
                date.isBefore(monthEnd.add(const Duration(seconds: 1)))) {
              final status = attendanceMap[dateStr];
              if (status == 'present') mPresent++;
              else if (status == 'absent') mAbsent++;
              else if (status == 'leave') mLeave++;
            }
          }

          // Calculate 30-Day Stats (Analytics)
          int p30 = 0, a30 = 0, l30 = 0;
          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 29)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
          for (var dateStr in attendanceMap.keys) {
            final date = DateFormat('yyyy-MM-dd').parse(dateStr);
            if (date.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1)))) {
              final status = attendanceMap[dateStr];
              if (status == 'present') p30++;
              else if (status == 'absent') a30++;
              else if (status == 'leave') l30++;
            }
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SingleChildScrollView(
              key: ValueKey(_selectedMonth),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    _buildSummaryCard(mPresent, mAbsent, mLeave),
                    const SizedBox(height: 12),
                    _buildTodayStatusCard(attendanceMap),
                    const SizedBox(height: 12),
                    _buildCalendarCard(attendanceMap),
                    const SizedBox(height: 12),
                    _buildOverviewCard(p30, a30, l30),
                    const SizedBox(height: 12),
                    _buildLastUpdatedFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENT 1: APPBAR ---
  PreferredSizeWidget _buildAppBar(String subtitle) {
    return AppBar(
      backgroundColor: colorDarkNavy,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            "Attendance",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: colorMutedBlue, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT 2: SUMMARY CARD ---
  Widget _buildSummaryCard(int p, int a, int l) {
    final int total = p + a + l;
    final int rate = total == 0 ? 0 : (p / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Stat Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(p.toString(), "PRESENT", colorPresent),
              _verticalDivider(),
              _statItem(a.toString(), "ABSENT", colorAbsent),
              _verticalDivider(),
              _statItem(l.toString(), "LEAVE", colorLeave),
              _verticalDivider(),
              _statItem(total.toString(), "TOTAL", colorTotal),
              _verticalDivider(),
              _statItem("$rate%", "RATE", colorRate),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: colorBorder),
          const SizedBox(height: 12),
          // Progress Bar Row
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : p / total,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEAEEF5),
                    valueColor: const AlwaysStoppedAnimation<Color>(colorPresent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text("$rate%", style: const TextStyle(color: colorRate, fontWeight: FontWeight.w700, fontSize: 11)),
              const SizedBox(width: 4),
              Text("$p of $total days", style: const TextStyle(color: colorGreyText, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- COMPONENT 3: TODAY STATUS CARD ---
  Widget _buildTodayStatusCard(Map<String, String> attendanceMap) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final status = attendanceMap[todayStr];
    
    String label = "Not Marked";
    Color dotColor = Colors.grey;
    Color bgColor = const Color(0xFFF5F5F5);
    Color textColor = Colors.grey;

    if (status == 'present') {
      label = "Present";
      dotColor = colorPresent;
      bgColor = const Color(0xFFE8F5EE);
      textColor = colorPresent;
    } else if (status == 'absent') {
      label = "Absent";
      dotColor = colorAbsent;
      bgColor = const Color(0xFFFDEAEA);
      textColor = colorAbsent;
    } else if (status == 'leave') {
      label = "On Leave";
      dotColor = colorLeave;
      bgColor = const Color(0xFFFFF8E1);
      textColor = colorLeave;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TODAY'S STATUS", style: TextStyle(fontSize: 10, color: colorGreyText, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
              Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorTotal)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT 4: CALENDAR CARD ---
  Widget _buildCalendarCard(Map<String, String> attendanceMap) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Month Nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _monthNavBtn(Icons.chevron_left, () => _changeMonth(-1)),
              Text(DateFormat('MMMM yyyy').format(_selectedMonth), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorTotal)),
              _monthNavBtn(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 12),
          // Day Headers
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
              final isWeekend = e.key >= 5;
              return Expanded(
                child: Center(
                  child: Text(e.value, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isWeekend ? colorAbsent : colorGreyText)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          _buildCalendarGrid(attendanceMap),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(colorPresent, "Present"),
              const SizedBox(width: 14),
              _legendItem(colorAbsent, "Absent"),
              const SizedBox(width: 14),
              _legendItem(colorLeave, "Leave"),
            ],
          ),
        ],
      ),
    );
  }

  // --- COMPONENT 5: OVERVIEW CARD ---
  Widget _buildOverviewCard(int p, int a, int l) {
    if (p + a + l == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Center(child: Text("No analytics data for last 30 days", style: TextStyle(color: colorGreyText, fontSize: 12))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Attendance Overview", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorTotal)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorRate.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: const Text("Last 30 Days", style: TextStyle(color: colorRate, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // PREMIUM 2.5D PIE CHART
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bottom Layer (Depth/Shadow)
                Transform.translate(
                  offset: const Offset(0, 4),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      startDegreeOffset: 270,
                      sections: _buildPieSections(p, a, l, true),
                    ),
                  ),
                ),
                // Top Layer (Surface/Gradient)
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: 270,
                    sections: _buildPieSections(p, a, l, false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _overviewLegend(colorPresent, "Present", p),
              _overviewLegend(colorAbsent, "Absent", a),
              _legendItem(colorLeave, "Leave"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewLegend(Color c, String l, int val) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text(l, style: const TextStyle(fontSize: 10, color: colorGreyText, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(int p, int a, int l, bool isBottom) {
    final total = p + a + l;
    if (total == 0) return [];

    return [
      _pieSection(p.toDouble(), colorPresent, isBottom),
      _pieSection(a.toDouble(), colorAbsent, isBottom),
      _pieSection(l.toDouble(), colorLeave, isBottom),
    ];
  }

  PieChartSectionData _pieSection(double val, Color c, bool isBottom) {
    if (isBottom) {
      return PieChartSectionData(
        color: c.withOpacity(0.35),
        value: val,
        radius: 20,
        showTitle: false,
      );
    } else {
      return PieChartSectionData(
        gradient: LinearGradient(
          colors: [c, Color.lerp(c, Colors.white, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        value: val,
        radius: 20,
        showTitle: false,
      );
    }
  }

  // --- HELPERS ---

  Stream<QuerySnapshot> _getUnifiedStream(String g, String d, String r) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    
    // Fetch from whichever is earlier
    final startDate = thirtyDaysAgo.isBefore(monthStart) ? thirtyDaysAgo : monthStart;
    
    return _attendanceService.streamCustomRangeAttendance(
      grade: g,
      div: d,
      grNo: r,
      start: startDate,
      end: DateTime.now().add(const Duration(days: 31)), // Ensure current month end is covered
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colorBorder, width: 0.5),
    );
  }

  Widget _statItem(String val, String label, Color c) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c)),
        Text(label, style: const TextStyle(fontSize: 9, color: colorGreyText, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _verticalDivider() => Container(width: 0.5, height: 20, color: colorBorder);

  Widget _monthNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(7), border: Border.all(color: colorBorder, width: 0.5)),
        child: Icon(icon, size: 16, color: colorTotal),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, String> attendanceMap) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final prevMonthLastDay = DateTime(_selectedMonth.year, _selectedMonth.month, 0);
    final leadingDays = firstDay.weekday - 1; // Mon=1
    
    final cells = <Widget>[];

    // Empty lead cells
    for (int i = 0; i < leadingDays; i++) {
      cells.add(const SizedBox());
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dStr = DateFormat('yyyy-MM-dd').format(date);
      final status = attendanceMap[dStr];
      final isToday = dStr == todayStr;
      final isWeekend = date.weekday >= 6;

      Color? bg, border, text = colorTotal;
      double borderWidth = 1.0;

      if (status == 'present') {
        bg = const Color(0xFFE8F5EE);
        border = const Color(0xFF8FCCA8);
        text = colorPresent;
      } else if (status == 'absent') {
        bg = const Color(0xFFFDEAEA);
        border = const Color(0xFFE8A0A0);
        text = colorAbsent;
      } else if (status == 'leave') {
        bg = const Color(0xFFFFF8E1);
        border = const Color(0xFFD8C070);
        text = colorLeave;
      }

      if (isToday) {
        border = colorRate;
        borderWidth = 2.0;
      }

      cells.add(
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bg ?? Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: border != null ? Border.all(color: border, width: borderWidth) : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: (status != null) ? text : (isWeekend ? colorAbsent : colorTotal),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7, 
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      children: cells,
    );
  }

  Widget _legendItem(Color c, String l) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(l, style: const TextStyle(fontSize: 10, color: colorGreyText, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLastUpdatedFooter() {
    String timeStr = "just now";
    if (_lastFetched != null) {
      timeStr = DateFormat('h:mm a').format(_lastFetched!);
    }
    return Center(
      child: Text("Updated today at $timeStr", style: const TextStyle(fontSize: 10, color: Color(0xFFA0AAB8))),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(child: CircularProgressIndicator(color: colorRate));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: colorAbsent, size: 48),
          const SizedBox(height: 16),
          const Text("Unable to load attendance", style: TextStyle(color: colorTotal, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => setState(() {}), child: const Text("Retry")),
        ],
      ),
    );
  }
}

// Extension to use streamCustomRangeAttendance
extension on AttendanceService {
  Stream<QuerySnapshot> streamCustomRangeAttendance({
    required String grade,
    required String div,
    required String grNo,
    required DateTime start,
    required DateTime end,
  }) {
    return FirebaseFirestore.instance
        .collection('students')
        .doc(grade)
        .collection('DIV_$div')
        .doc(grNo)
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots();
  }
}
