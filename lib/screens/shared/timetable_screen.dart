import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Timetable Screen – daily school timetable in a grid layout.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'Monday';
  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  Widget build(BuildContext context) {
    final entries = MockDataService.timetable.where((t) => t.day == _selectedDay).toList()
      ..sort((a, b) => a.period.compareTo(b.period));

    return Scaffold(
      appBar: const GradientAppBar(title: 'Timetable', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Day selector
          Container(
            height: 50, color: AppColors.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _days.length,
              itemBuilder: (context, i) {
                final selected = _days[i] == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = _days[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accent : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_days[i].substring(0, 3),
                        style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13,
                          color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                        )),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final color = AppColors.tileIconColors[i % AppColors.tileIconColors.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      // Period number
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Center(child: Text('${e.period}', style: TextStyle(fontWeight: FontWeight.w700, color: color))),
                      ),
                      const SizedBox(width: 12),
                      // Period details
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border(left: BorderSide(color: color, width: 3)),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(e.teacherName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ]),
                              Text(e.time, style: const TextStyle(fontSize: 11, color: AppColors.textSubtle, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Exam Timetable Screen – list of upcoming exam dates.
class ExamTimetableScreen extends StatelessWidget {
  const ExamTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = MockDataService.examTimetable;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Exam Timetable', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, i) {
          final e = exams[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${e.date.day}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.warning)),
                    Text(_monthShort(e.date.month), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warning)),
                  ]),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(e.examName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(e.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  String _monthShort(int m) {
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return months[m - 1];
  }
}
