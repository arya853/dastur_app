import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Academic Calendar Screen
///
/// Displays a monthly calendar with color-coded events:
/// holidays, exams, PTM days, and school events.
class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(2026, 3, 1);
  }

  @override
  Widget build(BuildContext context) {
    final events = MockDataService.calendarEvents;
    final monthEvents = events
        .where((e) =>
            e.date.month == _focusedMonth.month &&
            e.date.year == _focusedMonth.year)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Academic Calendar',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Month navigation
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1, 1);
                  }),
                ),
                Text(
                  _monthYearString(_focusedMonth),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1, 1);
                  }),
                ),
              ],
            ),
          ),
          // Day labels
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildCalendarGrid(events),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem(AppColors.error, 'Holiday'),
                _legendItem(AppColors.warning, 'Exam'),
                _legendItem(AppColors.info, 'Event'),
                _legendItem(AppColors.roleAdmin, 'PTM'),
              ],
            ),
          ),
          // Events list for the month
          const SectionHeader(title: 'Events This Month'),
          Expanded(
            child: monthEvents.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy,
                    message: 'No events this month')
                : ListView.builder(
                    itemCount: monthEvents.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final event = monthEvents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _eventColor(event.type)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${event.date.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: _eventColor(event.type),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                              ),
                            ),
                            StatusChip(
                              label: event.type.toUpperCase(),
                              color: _eventColor(event.type),
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

  Widget _buildCalendarGrid(List events) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun
    final totalDays = lastDay.day;

    final cells = <Widget>[];
    // Empty cells for days before the month starts
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    // Day cells
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dayEvents = MockDataService.calendarEvents
          .where((e) =>
              e.date.day == day &&
              e.date.month == _focusedMonth.month &&
              e.date.year == _focusedMonth.year)
          .toList();

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _selectedDate != null &&
                      _selectedDate!.day == day &&
                      _selectedDate!.month == _focusedMonth.month
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: date.weekday == DateTime.sunday
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayEvents
                        .take(3)
                        .map((e) => Container(
                              width: 5,
                              height: 5,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _eventColor(e.type),
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: cells,
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'holiday':
        return AppColors.error;
      case 'exam':
        return AppColors.warning;
      case 'ptm':
        return AppColors.roleAdmin;
      default:
        return AppColors.info;
    }
  }

  String _monthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
