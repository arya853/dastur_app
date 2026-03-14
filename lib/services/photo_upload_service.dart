import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class PhotoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery and upload to Firebase Storage
  /// Returns the download URL on success, null on failure.
  Future<String?> pickAndUploadPhoto({
    required String collection,
    required String documentId,
    required String folder,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
      );

      if (image == null) return null;

      File file = File(image.path);
      String fileName = '\${documentId}_\${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(folder).child(fileName);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore
      await _db.collection(collection).doc(documentId).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading photo: \$e");
      return null;
    }
  }
}
