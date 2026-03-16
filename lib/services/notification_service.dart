import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';

/// Notification Service
///
/// Handles FCM topic subscriptions and provides mock data for user notifications.
class NotificationService with ChangeNotifier {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Attendance Update',
      body: 'Your child was marked Present today at 08:15 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'attendance',
    ),
    AppNotification(
      id: '2',
      title: 'New Announcement',
      body: 'Check out the new announcement regarding the Annual Day function!',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'announcement',
      isRead: true,
    ),
    AppNotification(
      id: '3',
      title: 'Timetable Updated',
      body: 'The VIII-A Class Timetable has been updated for the next week.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: 'timetable',
    ),
    AppNotification(
      id: '4',
      title: 'Exam Schedule',
      body: 'Final Exam Timetable for Semester 2 has been uploaded.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: 'exam',
    ),
  ];

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  /// Subscribe to a specific topic (e.g., 'class_VIII_A')
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint("Subscribed to topic: $topic");
    } catch (e) {
      debugPrint("Error subscribing to topic $topic: $e");
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint("Unsubscribed from topic: $topic");
    } catch (e) {
      debugPrint("Error unsubscribing from topic $topic: $e");
    }
  }

  /// Demo notification trigger
  Future<void> sendNotification({
    required String title,
    required String body,
    required String topic,
  }) async {
    debugPrint("Triggering notification for topic '$topic': $title - $body");
  }

  /// Initialize and request permissions
  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }
}
