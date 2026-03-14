import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/student.dart';
import '../models/parent.dart';
import '../models/teacher.dart';
import '../models/announcement.dart';
import '../models/attendance_record.dart';
import '../models/fee_record.dart';
import '../models/timetable_entry.dart';
import '../models/subject.dart';
import '../models/ebook.dart';
import '../models/quiz.dart';
import '../models/calendar_event.dart';
import 'mock_data_service.dart';

class DataSeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      debugPrint("Starting database seed...");
      
      // 1. Users
      await _seedUsers();
      // 2. Students
      await _seedCollection(
        collection: 'students', 
        items: MockDataService.allStudents, 
        toMap: (item) => (item as Student).toMap(),
        getId: (item) => (item as Student).id,
      );
      // 3. Parents
      await _seedCollection(
        collection: 'parents', 
        items: MockDataService.allParents,
        toMap: (item) => (item as Parent).toMap(),
        getId: (item) => (item as Parent).id,
      );
      // 4. Teachers
      await _seedCollection(
        collection: 'teachers', 
        items: MockDataService.allTeachers, 
        toMap: (item) => (item as Teacher).toMap(),
        getId: (item) => (item as Teacher).id,
      );
      // 5. Announcements
      await _seedCollection(
        collection: 'announcements', 
        items: MockDataService.announcements, 
        toMap: (item) => (item as Announcement).toMap(),
        getId: (item) => (item as Announcement).id,
      );
      // 6. Attendance
      await _seedCollection(
        collection: 'attendance', 
        items: MockDataService.getAttendanceRecords(), 
        toMap: (item) => (item as AttendanceRecord).toMap(),
        getId: (item) => (item as AttendanceRecord).id,
      );
      // 7. Fees
      await _seedCollection(
        collection: 'fees', 
        items: [MockDataService.demoFeeRecord], 
        toMap: (item) => (item as FeeRecord).toMap(),
        getId: (item) => (item as FeeRecord).id,
      );
      // 8. Timetable
      await _seedCollection(
        collection: 'timetable', 
        items: MockDataService.timetable, 
        toMap: (item) => (item as TimetableEntry).toMap(),
        getId: (item) => (item as TimetableEntry).id,
      );
      // 9. Subjects
      await _seedCollection(
        collection: 'subjects', 
        items: MockDataService.subjects, 
        toMap: (item) => {
          'name': (item as Subject).name,
          'classId': item.classId,
          'chapters': item.chapters.map((c) => {'name': c.name, 'completed': c.completed}).toList(),
        },
        getId: (item) => (item as Subject).id,
      );
      // 10. Ebooks
      await _seedCollection(
        collection: 'ebooks', 
        items: MockDataService.ebooks, 
        toMap: (item) => (item as Ebook).toMap(),
        getId: (item) => (item as Ebook).id,
      );
      // 11. Practice Papers
      await _seedCollection(
        collection: 'practicePapers', 
        items: MockDataService.practicePapers, 
        toMap: (item) => (item as PracticePaper).toMap(),
        getId: (item) => (item as PracticePaper).id,
      );
      // 12. PTM
      await _seedCollection(
        collection: 'ptm', 
        items: MockDataService.ptmSchedule, 
        toMap: (item) => (item as Ptm).toMap(),
        getId: (item) => (item as Ptm).id,
      );
      // 13. Calendar Events
      await _seedCollection(
        collection: 'calendarEvents', 
        items: MockDataService.calendarEvents, 
        toMap: (item) => (item as CalendarEvent).toMap(),
        getId: (item) => (item as CalendarEvent).id,
      );
      // 14. Quizzes
      await _seedCollection(
        collection: 'quizzes', 
        items: MockDataService.quizzes, 
        toMap: (item) => (item as Quiz).toMap(),
        getId: (item) => (item as Quiz).id,
      );
      // 15. Exam Timetable
      await _seedCollection(
        collection: 'examTimetable', 
        items: MockDataService.examTimetable, 
        toMap: (item) => (item as ExamTimetableEntry).toMap(),
        getId: (item) => (item as ExamTimetableEntry).id,
      );

      debugPrint("Database seed completed successfully!");
    } catch (e) {
      debugPrint("Error seeding database: \$e");
      rethrow;
    }
  }

  Future<void> _seedUsers() async {
    // 1. Seed Admin Accounts
    for (var admin in MockDataService.adminAccounts) {
      await _createAuthUserAndProfile(admin, "admin123"); // Default admin password
    }

    // 2. Seed Teacher Accounts
    for (var teacher in MockDataService.allTeachers) {
      final appUser = AppUser(
        uid: teacher.id,
        email: teacher.email,
        displayName: teacher.name,
        role: 'teacher',
      );
      await _createAuthUserAndProfile(appUser, "teacher123");
    }

    // 3. Seed Parent Accounts
    // For many parents, we might want to limit this or use a default password based on GR No.
    // Let's seed the first 10 parents to demonstrate, others can be created on-demand or via admin panel.
    for (int i = 0; i < MockDataService.allParents.length; i++) {
      final parent = MockDataService.allParents[i];
      final appUser = AppUser(
        uid: parent.id,
        email: parent.email,
        displayName: parent.name,
        role: 'parent',
      );
      // Requirement: Default password is GR Number
      await _createAuthUserAndProfile(appUser, parent.linkedStudentGrNo);
      
      // Stop after 20 parents to avoid rate limiting during demo seeding
      if (i > 20) break;
    }
  }

  Future<void> _createAuthUserAndProfile(AppUser user, String password) async {
    try {
      // Note: In a real app, creating users from the client signs you in.
      // For seeding, it's better to use a backend or accept the login side effect for the last user.
      // We check if user exists first in Firestore to avoid duplicate auth calls if possible.
      
      UserCredential? cred;
      try {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          debugPrint("User \${user.email} already exists in Auth.");
          // We can't get the UID of an existing user easily without signing in,
          // so we'll just update the Firestore profile by searching by email if needed.
          // For now, assume IDs match or use a fixed UID for seeding if possible.
        } else {
          rethrow;
        }
      }

      final uid = cred?.user?.uid ?? user.uid;
      final updatedUser = AppUser(
        uid: uid,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
      );

      await _db.collection('users').doc(uid).set(updatedUser.toMap());
      debugPrint("Seeded user: \${user.email}");
    } catch (e) {
      debugPrint("Error seeding user \${user.email}: \$e");
    }
  }

  Future<void> _seedCollection({
    required String collection,
    required List<dynamic> items,
    required Map<String, dynamic> Function(dynamic) toMap,
    required String Function(dynamic) getId,
  }) async {
    debugPrint("Seeding \$collection...");
    WriteBatch batch = _db.batch();
    
    for (var item in items) {
      DocumentReference docRef = _db.collection(collection).doc(getId(item));
      batch.set(docRef, toMap(item), SetOptions(merge: true));
    }
    
    await batch.commit();
    debugPrint("Finished seeding \$collection");
  }
}
