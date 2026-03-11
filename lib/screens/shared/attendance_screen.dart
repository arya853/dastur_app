import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Attendance Calendar Screen – visual calendar with color-coded days.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(2026, 3, 1);
  }

  @override
  Widget build(BuildContext context) {
    final records = MockDataService.getAttendanceRecords();
    final present = records.where((r) => r.isPresent).length;
    final absent = records.where((r) => r.isAbsent).length;
    final leave = records.where((r) => r.isLeave).length;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Attendance', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                  _statItem('Absent', '$absent', AppColors.statusAbsent),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                  _statItem('Leave', '$leave', AppColors.statusLeave),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                  _statItem('Total', '${records.length}', AppColors.accent),
                ],
              ),
            ),
            // Month nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1))),
                  Text(_monthYear(_focusedMonth), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1))),
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
              child: _buildGrid(records),
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
      ),
    );
  }

  Widget _buildGrid(List records) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final cells = <Widget>[];
    for (int i = 1; i < firstDay.weekday; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final record = records.cast<dynamic>().where((r) => r.date.day == day && r.date.month == _focusedMonth.month).toList();
      Color? bgColor;
      if (record.isNotEmpty) {
        final status = record.first.status;
        if (status == 'present') {
          bgColor = AppColors.statusPresent;
        } else if (status == 'absent') {
          bgColor = AppColors.statusAbsent;
        } else {
          bgColor = AppColors.statusLeave;
        }
      }
      cells.add(Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor?.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: bgColor != null ? Border.all(color: bgColor.withValues(alpha: 0.5), width: 1.5) : null,
        ),
        child: Center(child: Text('$day', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: date.weekday == DateTime.sunday ? AppColors.error : AppColors.textPrimary,
        ))),
      ));
    }
    return GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.1, children: cells);
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
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3), border: Border.all(color: color, width: 1.5))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  String _monthYear(DateTime d) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[d.month - 1]} ${d.year}';
  }
}
