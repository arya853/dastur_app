/// Represents a single day's attendance record for a student.
class AttendanceRecord {
  final String id;
  final String studentId;
  final DateTime date;
  final String status; // 'present', 'absent', 'leave'
  final String? markedBy; // teacher ID who marked it

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.markedBy,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecord(
      id: id,
      studentId: map['studentId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'present',
      markedBy: map['markedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': date.toIso8601String(),
      'status': status,
      'markedBy': markedBy,
    };
  }

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLeave => status == 'leave';
}
