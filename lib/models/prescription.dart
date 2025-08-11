import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single prescription record.
class Prescription {
  final String id;
  final String imageUrl;
  final String recognizedText;
  final Timestamp createdAt;

  Prescription({
    required this.id,
    required this.imageUrl,
    required this.recognizedText,
    required this.createdAt,
  });

  /// Converts the object to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'recognizedText': recognizedText,
      'createdAt': createdAt,
    };
  }

  /// Creates a [Prescription] from a Firestore document.
  factory Prescription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prescription(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      recognizedText: data['recognizedText'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
