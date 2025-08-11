import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service to handle file uploads to Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads a prescription image and returns the download URL.
  Future<String?> uploadPrescriptionImage(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Create a unique file name for the image.
      final fileName = 'prescriptions/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      // Upload the file.
      final uploadTask = await ref.putFile(imageFile);

      // Get the download URL.
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
