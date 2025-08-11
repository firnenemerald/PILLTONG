import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/prescription.dart';

/// A service to handle Firestore database operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a new prescription document for the current user.
  Future<void> addPrescription(Prescription prescription) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('prescriptions')
        .add(prescription.toMap());
  }
}
