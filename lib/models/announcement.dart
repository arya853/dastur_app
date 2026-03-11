/// Represents a school announcement / circular / notice.
class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String type;       // 'circular', 'notice', 'alert', 'event'
  final String authorId;
  final String authorName;
  final String? targetClass; // null = school-wide

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    required this.authorId,
    required this.authorName,
    this.targetClass,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String id) {
    return Announcement(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? 'notice',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      targetClass: map['targetClass'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'type': type,
      'authorId': authorId,
      'authorName': authorName,
      'targetClass': targetClass,
    };
  }

  /// Whether this targets a specific class or the entire school
  bool get isSchoolWide => targetClass == null;
}
