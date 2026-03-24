import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../main.dart'; // To access navigatorKey

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel_v2',
    'High Importance Notifications',
    description: 'This channel is used for important school notifications.',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> init() async {
    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM permission authorized');
    } else {
      debugPrint('FCM permission declined');
    }

    // 2. Initialize Local Notifications (for Foreground)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Local Notification Clicked: ${response.payload}");
        // We pass a dummy message with the payload data
        final data = response.payload != null ? json.decode(response.payload!) as Map<String, dynamic> : <String, dynamic>{};
        handleNotificationClick(RemoteMessage(data: data));
      },
    );

    final plugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.createNotificationChannel(_channel);
    }

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 4. Handle Background Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
    });
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
      return null;
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final String jsonString = await rootBundle.loadString('serviceAccountKey.json');
      final Map<String, dynamic> serviceAccountJson = json.decode(jsonString);
      
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      final authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
      return authClient.credentials.accessToken.data;
    } catch (e) {
      debugPrint("Error generating OAuth token: $e");
      return null;
    }
  }

  /// Sends a push notification using the FCM HTTP v1 API.
  Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    String? type,
  }) async {
    if (fcmToken.isEmpty) {
      debugPrint("Cannot send FCM: token is empty.");
      return false;
    }

    try {
      final String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        debugPrint("FCM Push failed: Unable to retrieve access token.");
        return false;
      }

      // Hardcode or extract project ID from serviceAccountKey
      const String projectId = 'dasturapp';

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'priority': 'HIGH',
              'notification': {
                'channel_id': _channel.id,
                'sound': 'default',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              }
            },
            'data': {
              'type': type ?? 'general',
              'status': 'done',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("FCM Push sent successfully to $fcmToken");
        return true;
      } else {
        debugPrint("FCM Push failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error sending FCM Push: $e");
      return false;
    }
  }
}
