import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a single medication item.
///
/// This class is used to structure medication data, convert it to and from
/// the format required by Firestore, and ensure type safety.
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final List<String>? customNotificationTimes; // Store as HH:MM format
  final bool notificationsEnabled;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.customNotificationTimes,
    this.notificationsEnabled = true,
  });

  /// Converts the [Medication] object into a Map\<String, dynamic>
  /// that can be stored in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'customNotificationTimes': customNotificationTimes,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  /// Creates a [Medication] object from a Firestore document snapshot.
  /// This is essential for reading data from the database.
  factory Medication.fromFirestore(DocumentSnapshot doc) {
    // Cast the data from the document to a Map.
    final data = doc.data() as Map<String, dynamic>;

    // Return a new Medication instance with the data from the map.
    // We use null-coalescing operators (??) to provide default values
    // in case a field is missing from the database document.
    return Medication(
      name: data['name'] ?? 'No Name',
      dosage: data['dosage'] ?? 'No Dosage',
      frequency: data['frequency'] ?? 'No Frequency',
      customNotificationTimes: data['customNotificationTimes'] != null
          ? List<String>.from(data['customNotificationTimes'])
          : null,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  // Helper method to get notification times as TimeOfDay objects
  List<TimeOfDay> getNotificationTimes() {
    if (customNotificationTimes != null && customNotificationTimes!.isNotEmpty) {
      return customNotificationTimes!.map((timeString) {
        final parts = timeString.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    }

    // Default times based on frequency
    if (frequency.toLowerCase().contains('3 times a day')) {
      return [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 14, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ];
    } else if (frequency.toLowerCase().contains('twice a day')) {
      return [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 21, minute: 0),
      ];
    } else {
      return [TimeOfDay(hour: 9, minute: 0)];
    }
  }
}
