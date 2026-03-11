/// Timetable entry for a single period in a day.
class TimetableEntry {
  final String id;
  final String classId;  // e.g., 'VIII-A'
  final String day;      // 'Monday', 'Tuesday', etc.
  final int period;      // 1, 2, 3...
  final String subject;
  final String teacherName;
  final String time;     // e.g., '8:00 - 8:40'

  TimetableEntry({
    required this.id,
    required this.classId,
    required this.day,
    required this.period,
    required this.subject,
    required this.teacherName,
    required this.time,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> map, String id) {
    return TimetableEntry(
      id: id,
      classId: map['classId'] ?? '',
      day: map['day'] ?? '',
      period: map['period'] ?? 0,
      subject: map['subject'] ?? '',
      teacherName: map['teacherName'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'day': day,
      'period': period,
      'subject': subject,
      'teacherName': teacherName,
      'time': time,
    };
  }
}

/// Exam timetable entry — date-based exam schedule.
class ExamTimetableEntry {
  final String id;
  final String classId;
  final String examName; // e.g., 'Unit Test 1', 'Final Exam'
  final DateTime date;
  final String subject;
  final String time;     // e.g., '10:00 AM - 12:00 PM'

  ExamTimetableEntry({
    required this.id,
    required this.classId,
    required this.examName,
    required this.date,
    required this.subject,
    required this.time,
  });

  factory ExamTimetableEntry.fromMap(Map<String, dynamic> map, String id) {
    return ExamTimetableEntry(
      id: id,
      classId: map['classId'] ?? '',
      examName: map['examName'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      subject: map['subject'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'examName': examName,
      'date': date.toIso8601String(),
      'subject': subject,
      'time': time,
    };
  }
}
