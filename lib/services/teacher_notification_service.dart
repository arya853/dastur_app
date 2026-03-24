import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/fcm_service.dart';

class TeacherNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FcmService _fcmService = FcmService();

  /// Sends a notification to all students in the teacher's assigned CLASS and DIV.
  Future<void> sendNotificationToClass({
    required String teacherEmail,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      // 1. Fetch teacher details - Direct doc reference is fastest since ID is the email
      DocumentSnapshot teacherDoc = await _db
          .collection('teachers')
          .doc(teacherEmail.toLowerCase())
          .get();

      if (!teacherDoc.exists) {
        // Fallback: Query by email field if doc ID doesn't match email perfectly
        final query = await _db.collection('teachers').where('email', isEqualTo: teacherEmail.toLowerCase()).get();
        if (query.docs.isNotEmpty) {
          teacherDoc = query.docs.first;
        } else {
          throw "Teacher record not found for email $teacherEmail.";
        }
      }

      final teacherData = teacherDoc.data() as Map<String, dynamic>;
      final dynamic rawClass = teacherData['CLASS'] ?? teacherData['class'];
      final teacherClass = rawClass?.toString();
      final teacherDiv = teacherData['DIV'] ?? teacherData['div'];

      if (teacherClass == null || teacherDiv == null) {
        throw "You do not have a CLASS or DIV assigned. Please contact the administrator.";
      }

      // 2. Map class to grade collection (e.g., '5' -> 'grade5')
      String targetGrade = _classToGrade(teacherClass);

      // 3. Query matching students
      final studentsSnapshot = await _db
          .collection('students')
          .doc(targetGrade)
          .collection('DIV_A')
          .where('CLASS', isEqualTo: teacherClass)
          .where('DIV', isEqualTo: teacherDiv)
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        throw "No students found for Class $teacherClass Div $teacherDiv.";
      }

      // 4. Batch write notifications and trigger FCM
      final batch = _db.batch();

      for (var studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final fcmToken = studentData['fcmToken'];

        // Send FCM
        if (fcmToken != null && fcmToken.isNotEmpty) {
          _fcmService.sendPushNotification(
            fcmToken: fcmToken,
            title: title,
            body: message,
            type: type,
          ).catchError((e) {
            debugPrint("FCM failed for one student: $e");
            return false;
          });
        }

        // Prepare Firestore document
        final notificationRef = studentDoc.reference.collection('notifications').doc();
        batch.set(notificationRef, {
          'title': title,
          'message': message,
          'type': type,
          'senderRole': 'teacher',
          'senderEmail': teacherEmail,
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
          'readAt': null,
        });
      }

      await batch.commit();
      debugPrint("Successfully sent notifications to ${studentsSnapshot.docs.length} students.");
      
    } catch (e) {
      debugPrint("Error in TeacherNotificationService: $e");
      rethrow;
    }
  }

  String _classToGrade(String className) {
    if (className == '5' || className == 'V') return 'grade5';
    if (className == '6' || className == 'VI') return 'grade6';
    if (className == '7' || className == 'VII') return 'grade7';
    if (className == '8' || className == 'VIII') return 'grade8';
    return className.toLowerCase().startsWith('grade') ? className.toLowerCase() : 'grade$className';
  }
}
