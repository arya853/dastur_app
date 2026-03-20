import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  static Future<void> seedData() async {
    print('Starting data seeding...');
    final firestore = FirebaseFirestore.instance;
    final grades = ['5', '6', '7', '8'];
    
    // Using current directory as base
    final baseDir = Directory.current.path;
    print('Base directory: $baseDir');

    for (var grade in grades) {
      final fileName = 'tableConvert.com_grade$grade.json';
      final file = File('$baseDir\\$fileName');
      
      if (!await file.exists()) {
        print('🔴 File not found: ${file.path}');
        continue;
      }

      print('Processing $fileName...');
      try {
        final content = await file.readAsString();
        final List<dynamic> data = json.decode(content);

        for (var student in data) {
          final grNo = student['GR NO.'];
          if (grNo == null) continue;

          // Handle inconsistent casing in MOTHER'S NAME
          final motherName = student["MOTHER'S NAME"] ?? student["Mother's NAME"];
          final fatherName = student["Father's NAME"];

          if (motherName == null && fatherName == null) continue;

          final updates = <String, dynamic>{};
          if (fatherName != null) updates["Father's NAME"] = fatherName;
          if (motherName != null) updates["Mother's NAME"] = motherName;

          await firestore
              .collection('students')
              .doc('grade$grade')
              .collection('list')
              .doc(grNo)
              .set(updates, SetOptions(merge: true));
          
          print('✅ Updated student $grNo in grade$grade');
        }
      } catch (e) {
        print('❌ Error processing $grade: $e');
      }
    }
    print('🏁 Seeding completed successfully!');
  }
}
