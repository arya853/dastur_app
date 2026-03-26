import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all students for a specific grade and division.
  /// Uses the 'DIV_A' collection for consistency with existing data.
  Future<List<Map<String, dynamic>>> fetchStudentsForClass(String grade, String div) async {
    try {
      final snapshot = await _db
          .collection('students')
          .doc(grade)
          .collection('DIV_$div')
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      throw 'Failed to fetch students: $e';
    }
  }

  /// Marks attendance for a single student.
  /// Path: students/{grade}/DIV_{div}/{grNo}/attendance/{dateId}
  Future<void> markAttendance({
    required String grade,
    required String div,
    required String grNo,
    required String dateId,
    required String status,
    required String teacherEmail,
  }) async {
    try {
      final dateValue = DateTime.parse(dateId);
      final attendanceDoc = _db
          .collection('students')
          .doc(grade)
          .collection('DIV_$div')
          .doc(grNo)
          .collection('attendance')
          .doc(dateId);

      await attendanceDoc.set({
        'date': Timestamp.fromDate(DateTime(dateValue.year, dateValue.month, dateValue.day)),
        'status': status,
        'markedBy': teacherEmail,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to mark attendance for $grNo: $e';
    }
  }

  /// Streams attendance records for a specific month.
  /// Path: students/{grade}/DIV_{div}/{grNo}/attendance/
  Stream<QuerySnapshot> streamMonthAttendance({
    required String grade,
    required String div,
    required String grNo,
    required DateTime month,
  }) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _db
        .collection('students')
        .doc(grade)
        .collection('DIV_$div')
        .doc(grNo)
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(monthEnd))
        .snapshots();
  }

  /// Fetches the attendance summary for a class on a specific date.
  Future<Map<String, dynamic>?> fetchAttendanceSummary(String grade, String div, String dateId) async {
    try {
      final doc = await _db.collection('attendance_summaries').doc('${grade}_${div}_$dateId').get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Saves the attendance summary for a class on a specific date.
  Future<void> saveAttendanceSummary({
    required String grade,
    required String div,
    required String dateId,
    required String teacherName,
    required String teacherEmail,
  }) async {
    try {
      await _db.collection('attendance_summaries').doc('${grade}_${div}_$dateId').set({
        'grade': grade,
        'div': div,
        'dateId': dateId,
        'submittedAt': FieldValue.serverTimestamp(),
        'submittedBy': teacherName,
        'teacherEmail': teacherEmail,
        'status': 'submitted',
      });
    } catch (e) {
      throw 'Failed to save attendance summary: $e';
    }
  }

  /// Fetches attendance records for all students in a class for a specific date.
  Future<Map<String, String>> fetchClassAttendance(String grade, String div, String dateId) async {
    final students = await fetchStudentsForClass(grade, div);
    final attendanceMap = <String, String>{};
    
    final futures = students.map((s) async {
      final grNo = s['id'];
      final doc = await _db
          .collection('students')
          .doc(grade)
          .collection('DIV_$div')
          .doc(grNo)
          .collection('attendance')
          .doc(dateId)
          .get();
      
      if (doc.exists) {
        return MapEntry(grNo, doc.data()?['status'] as String? ?? 'present');
      }
      return null;
    });

    final results = await Future.wait(futures);
    for (var res in results) {
      if (res != null) {
        attendanceMap[res.key] = res.value;
      }
    }
    return attendanceMap;
  }
}
