import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // List of all grades being managed (5-10)
  static const List<String> availableGrades = [
    'grade5', 'grade6', 'grade7', 'grade8', 'grade9', 'grade10'
  ];
  
  // List of possible divisions
  static const List<String> availableDivisions = ['A', 'B'];

  /// Fetches all students from across all grade collections and divisions.
  Future<List<Student>> fetchAllStudents() async {
    final List<Student> allStudents = [];
    
    try {
      // We fetch each grade and division in parallel for better performance
      final List<Future<QuerySnapshot>> futures = [];
      
      for (final grade in availableGrades) {
        for (final div in availableDivisions) {
          futures.add(
            _db.collection('students')
              .doc(grade)
              .collection('DIV_$div')
              .get()
          );
        }
      }
      
      final snapshots = await Future.wait(futures);
      
      for (final snapshot in snapshots) {
        allStudents.addAll(
          snapshot.docs.map((doc) => 
            Student.fromMap(doc.data() as Map<String, dynamic>, doc.id)
          )
        );
      }
      
      return allStudents;
    } catch (e) {
      throw 'Failed to fetch all students: $e';
    }
  }

  /// Streams the total student count across all grades.
  /// (Note: For large datasets, a cloud function or counter document is better)
  Stream<int> streamTotalStudentCount() async* {
    // This is a simple implementation that sums counts from all class collections.
    // In production, you'd likely use a dedicated metadata document.
    while (true) {
      int count = 0;
      final students = await fetchAllStudents();
      count = students.length;
      yield count;
      await Future.delayed(const Duration(minutes: 5)); // Refresh every 5 mins
    }
  }
}
