import 'package:cloud_firestore/cloud_firestore.dart';

class ExamSyllabusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'exam_syllabus';

  /// Stream all exams for a specific class (grade + div)
  Stream<QuerySnapshot> streamExamsForClass(String grade, String div) {
    return _db
        .collection(_collection)
        .where('grade', isEqualTo: grade)
        .where('div', isEqualTo: div)
        .snapshots();
  }

  /// Save or Update an exam syllabus
  Future<void> saveExamSyllabus({
    required String grade,
    required String div,
    required String examName,
    required Map<String, String> subjects,
  }) async {
    final docId = '${grade}_${div}_${examName.replaceAll(' ', '_')}';
    
    await _db.collection(_collection).doc(docId).set({
      'grade': grade,
      'div': div,
      'examName': examName,
      'subjects': subjects,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete an exam syllabus
  Future<void> deleteExamSyllabus(String docId) async {
    await _db.collection(_collection).doc(docId).delete();
  }
}
