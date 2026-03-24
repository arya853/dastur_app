import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'attendance' / 'announcement' / 'general'
  final String senderRole;
  final String senderEmail;
  bool isRead;
  final DateTime timestamp;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.senderRole,
    required this.senderEmail,
    this.isRead = false,
    required this.timestamp,
    this.readAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      senderRole: data['senderRole'] ?? 'teacher',
      senderEmail: data['senderEmail'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'senderRole': senderRole,
      'senderEmail': senderEmail,
      'isRead': isRead,
      'timestamp': FieldValue.serverTimestamp(),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }
}
