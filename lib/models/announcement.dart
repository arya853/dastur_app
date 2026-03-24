import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String targetRole;   // 'all', 'students', 'teachers'
  final DateTime? createdAt;
  final bool isActive;
  final String? imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    required this.authorId,
    required this.authorName,
    this.targetClass,
    this.targetRole = 'all',
    this.createdAt,
    this.isActive = true,
    this.imageUrl,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String id) {
    return Announcement(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.parse(map['date']?.toString() ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? 'notice',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      targetClass: map['targetClass'],
      targetRole: map['targetRole'] ?? 'all',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : null),
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': Timestamp.fromDate(date),
      'type': type,
      'authorId': authorId,
      'authorName': authorName,
      'targetClass': targetClass,
      'targetRole': targetRole,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  /// Whether this targets a specific class or the entire school
  bool get isSchoolWide => targetClass == null;
}

