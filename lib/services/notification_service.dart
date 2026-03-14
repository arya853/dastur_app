import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Notification Service
///
/// Handles FCM topic subscriptions and sending notification triggers.
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

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

  /// In a production app, notifications are sent from the backend (Firebase Admin SDK).
  /// For this portal demo, we simulate the trigger.
  Future<void> sendNotification({
    required String title,
    required String body,
    required String topic,
  }) async {
    debugPrint("Triggering notification for topic '$topic': $title - $body");
    
    // Note: To actually send a message from the app, you'd need a backend service or 
    // to use the FCM HTTP v1 API with a short-lived token.
    // We will simulate the 'Success' result for now.
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
