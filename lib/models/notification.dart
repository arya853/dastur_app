class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'attendance', 'announcement', 'event', 'timetable', 'exam'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}
