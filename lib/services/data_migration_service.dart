import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One-time migration script to move students from 'list' to 'DIV_A'
class DataMigrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> migrateStudentsListToDivA() async {
    final grades = ['grade5', 'grade6', 'grade7', 'grade8'];

    for (final grade in grades) {
      debugPrint("Checking $grade for migration...");
      final sourceRef = _db.collection('students').doc(grade).collection('list');
      final targetRef = _db.collection('students').doc(grade).collection('DIV_A');

      final snapshot = await sourceRef.get();
      if (snapshot.docs.isEmpty) {
        debugPrint("No students found in $grade/list or already migrated.");
        continue;
      }

      debugPrint("Migrating ${snapshot.docs.length} students in $grade...");
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        // Copy data and set DIV to 'A'
        final data = doc.data();
        data['DIV'] = 'A';
        batch.set(targetRef.doc(doc.id), data);
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint("Successfully migrated $grade.");
    }
    debugPrint("Migration complete.");
  }
}
