import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/notification.dart';

class NotificationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a real-time stream of notifications from the Firestore subcollection.
  Stream<List<AppNotification>> getNotificationsStream(String grade, String grNo) {
    return _db
        .collection('students')
        .doc(grade)
        .collection('DIV_A')
        .doc(grNo)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppNotification.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// Returns a stream of the total unread notifications count
  Stream<int> getUnreadCountStream(String grade, String grNo) {
    return _db
        .collection('students')
        .doc(grade)
        .collection('DIV_A')
        .doc(grNo)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark as read
  Future<void> markAsRead(String grade, String grNo, String notificationId) async {
    try {
      await _db
          .collection('students')
          .doc(grade)
          .collection('DIV_A')
          .doc(grNo)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead(String grade, String grNo) async {
    try {
      final unreadDocs = await _db
          .collection('students')
          .doc(grade)
          .collection('DIV_A')
          .doc(grNo)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadDocs.docs.isEmpty) return;

      final batch = _db.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }
}
