import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all teachers from the Firestore 'teachers' collection.
  Future<List<Map<String, dynamic>>> fetchAllTeachers() async {
    try {
      final snapshot = await _db.collection('teachers').get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      throw 'Failed to fetch all teachers: $e';
    }
  }

  /// Streams the total teacher count.
  Stream<int> streamTotalTeacherCount() {
    return _db.collection('teachers').snapshots().map((snapshot) => snapshot.docs.length);
  }
}
