import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get students => _db.collection('students');
  CollectionReference get attendance => _db.collection('attendance');
  CollectionReference get announcements => _db.collection('announcements');
  CollectionReference get timetable => _db.collection('timetable');
  CollectionReference get fees => _db.collection('fees');

  /// Fetches a student document by their GR Number
  Future<DocumentSnapshot> getStudentByGrNo(String grNo) async {
    final query = await students.where('grNo', isEqualTo: grNo).limit(1).get();
    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    throw Exception('Student with GR No $grNo not found');
  }

  /// Example: Add announcement
  Future<DocumentReference> addAnnouncement(Map<String, dynamic> data) async {
    return await announcements.add(data);
  }

  /// Example: Get all announcements
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return announcements.orderBy('date', descending: true).snapshots();
  }
}
