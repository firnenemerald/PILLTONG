import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/models/medication.dart';
import 'package:pilltongapp/services/notification_service.dart';

/// Service for managing medications and their notifications
class MedicationService {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Deletes a medication and cancels its notifications
  Future<void> deleteMedication(String medicationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Cancel notifications first
      await _notificationService.cancelMedicationNotifications(medicationId);
      
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(medicationId)
          .delete();
    } catch (e) {
      print('Error deleting medication: $e');
      rethrow;
    }
  }

  /// Schedules notifications for all medications
  Future<void> rescheduleAllNotifications() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Initialize notification service first
      await _notificationService.initialize();
      
      // Get all medications
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .where('notificationsEnabled', isEqualTo: true)
          .get();

      // Schedule notifications for each medication
      for (final doc in snapshot.docs) {
        try {
          final medication = Medication.fromFirestore(doc);
          final notificationTimes = medication.getNotificationTimes();
          
          if (notificationTimes.isNotEmpty) {
            await _notificationService.scheduleMedicationNotifications(
              medicationId: doc.id,
              medicationName: medication.name,
              times: notificationTimes,
            );
          }
        } catch (e) {
          print('Error scheduling notifications for medication ${doc.id}: $e');
          // Continue with other medications
        }
      }
    } catch (e) {
      print('Error rescheduling notifications: $e');
      rethrow;
    }
  }

  /// Toggles notification for a specific medication
  Future<void> toggleNotification(String medicationId, bool enabled) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Update Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(medicationId)
          .update({'notificationsEnabled': enabled});

      if (enabled) {
        // Get medication data and schedule notifications
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('medications')
            .doc(medicationId)
            .get();
        
        if (doc.exists) {
          final medication = Medication.fromFirestore(doc);
          final notificationTimes = medication.getNotificationTimes();
          
          if (notificationTimes.isNotEmpty) {
            try {
              await _notificationService.scheduleMedicationNotifications(
                medicationId: medicationId,
                medicationName: medication.name,
                times: notificationTimes,
              );
            } catch (e) {
              print('Error scheduling notifications: $e');
              // Don't rethrow here to allow the UI toggle to work
            }
          }
        }
      } else {
        // Cancel notifications
        try {
          await _notificationService.cancelMedicationNotifications(medicationId);
        } catch (e) {
          print('Error cancelling notifications: $e');
          // Don't rethrow here to allow the UI toggle to work
        }
      }
    } catch (e) {
      print('Error toggling notification: $e');
      rethrow;
    }
  }
}
