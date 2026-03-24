import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import 'fcm_service.dart';

class AdminAnnouncementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FcmService _fcmService = FcmService();

  /// Create an announcement globally and fan it out to targeted users.
  Future<void> createAnnouncement(Announcement announcement) async {
    try {
      // 1. Create the global announcement document
      final docRef = _db.collection('announcements').doc(announcement.id);
      await docRef.set(announcement.toMap());

      // 2. Fan-out
      _fanOutAndPush(announcement);
    } catch (e) {
      debugPrint("Error creating announcement: $e");
      rethrow;
    }
  }

  /// Runs in background to fan out notifications and dispatch push alerts.
  Future<void> _fanOutAndPush(Announcement ann) async {
    try {
      final List<Map<String, dynamic>> targets = []; // { 'ref': DocumentReference, 'token': String }

      // Gather Students
      if (ann.targetRole == 'all' || ann.targetRole == 'students') {
        List<String> grades = const ['grade5', 'grade6', 'grade7', 'grade8'];
        if (ann.targetClass != null && ann.targetClass!.isNotEmpty) {
          final mapped = _classToGrade(ann.targetClass!);
          if (mapped != null) grades = [mapped];
        }

        for (final grade in grades) {
          Query query = _db.collection('students').doc(grade).collection('DIV_A');
          if (ann.targetClass != null && ann.targetClass!.isNotEmpty) {
            query = query.where('CLASS', isEqualTo: ann.targetClass);
          }
          final snap = await query.get();
          for (var doc in snap.docs) {
            final data = doc.data() as Map<String, dynamic>;
            targets.add({
              'ref': doc.reference,
              'token': data['fcmToken'],
            });
          }
        }
      }

      // Gather Teachers
      if (ann.targetRole == 'all' || ann.targetRole == 'teachers') {
        Query query = _db.collection('teachers');
        if (ann.targetClass != null && ann.targetClass!.isNotEmpty) {
          query = query.where('CLASS', isEqualTo: ann.targetClass);
        }
        final snap = await query.get();
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          targets.add({
            'ref': doc.reference,
            'token': data['fcmToken'],
          });
        }
      }

      if (targets.isEmpty) return;

      // Batch Write & Push
      // Firestore batch size limit is 500. We'll chunk to 400 for safety.
      for (var i = 0; i < targets.length; i += 400) {
        final chunk = targets.sublist(i, i + 400 > targets.length ? targets.length : i + 400);
        final batch = _db.batch();
        
        for (final target in chunk) {
          final DocumentReference parentRef = target['ref'];
          final String? token = target['token'];

          // Prepare notification document
          final notifRef = parentRef.collection('notifications').doc(ann.id);
          batch.set(notifRef, {
            'title': ann.title,
            'message': ann.body,
            'type': ann.type,
            'senderRole': 'admin',
            'senderEmail': ann.authorId,
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
            'readAt': null,
          });

          // Dispatch FCM
          if (token != null && token.isNotEmpty) {
            _fcmService.sendPushNotification(
              fcmToken: token,
              title: ann.title,
              body: ann.body,
              type: ann.type,
            ).catchError((e) {
              debugPrint("FCM Push failed for $token: $e");
              return false;
            });
          }
        }
        
        await batch.commit();
      }

      debugPrint("Successfully broadcasted to ${targets.length} users.");
    } catch (e) {
      debugPrint("Error during fanOutAndPush: $e");
    }
  }

  /// Delete an announcement globally
  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  /// Toggle active state
  Future<void> toggleActive(String id, bool currentState) async {
    await _db.collection('announcements').doc(id).update({
      'isActive': !currentState,
    });
  }

  String? _classToGrade(String className) {
    if (className == '5' || className == 'V') return 'grade5';
    if (className == '6' || className == 'VI') return 'grade6';
    if (className == '7' || className == 'VII') return 'grade7';
    if (className == '8' || className == 'VIII') return 'grade8';
    return null;
  }
}
