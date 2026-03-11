/// Represents a PTM (Parent Teacher Meeting) schedule.
class Ptm {
  final String id;
  final String classId;
  final DateTime date;
  final String teacherName;
  final String instructions;

  Ptm({
    required this.id,
    required this.classId,
    required this.date,
    required this.teacherName,
    required this.instructions,
  });

  factory Ptm.fromMap(Map<String, dynamic> map, String id) {
    return Ptm(
      id: id,
      classId: map['classId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      teacherName: map['teacherName'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'date': date.toIso8601String(),
      'teacherName': teacherName,
      'instructions': instructions,
    };
  }
}

/// Represents an event on the academic calendar.
class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final String type; // 'holiday', 'exam', 'ptm', 'event'
  final String? createdBy;

  CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    this.createdBy,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map, String id) {
    return CalendarEvent(
      id: id,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      title: map['title'] ?? '',
      type: map['type'] ?? 'event',
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'type': type,
      'createdBy': createdBy,
    };
  }
}

/// Represents a downloadable practice paper.
class PracticePaper {
  final String id;
  final String title;
  final String subject;
  final String classId;
  final String examType; // 'unit_test', 'midterm', 'final', 'practice'
  final String pdfUrl;
  final String? uploadedBy;

  PracticePaper({
    required this.id,
    required this.title,
    required this.subject,
    required this.classId,
    required this.examType,
    required this.pdfUrl,
    this.uploadedBy,
  });

  factory PracticePaper.fromMap(Map<String, dynamic> map, String id) {
    return PracticePaper(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      classId: map['classId'] ?? '',
      examType: map['examType'] ?? 'practice',
      pdfUrl: map['pdfUrl'] ?? '',
      uploadedBy: map['uploadedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'classId': classId,
      'examType': examType,
      'pdfUrl': pdfUrl,
      'uploadedBy': uploadedBy,
    };
  }
}
