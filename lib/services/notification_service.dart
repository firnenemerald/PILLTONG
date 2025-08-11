import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// A service class for handling local notifications.
///
/// This service initializes the notification plugin, requests permissions,
/// and provides methods to schedule notifications.
class NotificationService {
  // Singleton instance of the service
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  /// Initializes the notification service.
  ///
  /// This method sets up the timezone database, configures platform-specific
  /// settings, and requests necessary permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 1. Initialize the timezone database
      tz.initializeTimeZones();
      
      // 2. Get the local timezone
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      
      // 3. Set the local location using the correct variable
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      // 4. Configure Android settings
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 5. Configure iOS settings
      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 6. Initialize the plugin with the platform settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 7. Request notification permissions for Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Request permissions
      final bool? permissionResult = await androidImplementation?.requestNotificationsPermission();
      
      // Request exact alarm permission for Android 12+
      final bool? exactAlarmResult = await androidImplementation?.requestExactAlarmsPermission();
      
      print('Notification permission: $permissionResult');
      print('Exact alarm permission: $exactAlarmResult');
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notifications: $e');
      // Don't set _isInitialized to true if there was an error
      rethrow;
    }
  }

  /// Schedules a daily notification at a specific time.
  ///
  /// This function uses Flutter's built-in TimeOfDay class.
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_notification_channel_id',
            'Daily Notifications',
            channelDescription: 'Channel for daily medication reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        // The deprecated 'androidAllowWhileIdle' has been replaced with 'androidScheduleMode'.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Schedules multiple notifications for a medication
  Future<void> scheduleMedicationNotifications({
    required String medicationId,
    required String medicationName,
    required List<TimeOfDay> times,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // Cancel existing notifications for this medication first
      await cancelMedicationNotifications(medicationId);

      // Schedule new notifications
      for (int i = 0; i < times.length; i++) {
        final notificationId = _generateNotificationId(medicationId, i);
        await scheduleDailyNotification(
          id: notificationId,
          title: '💊 복용 시간 알림',
          body: '$medicationName 복용 시간입니다',
          time: times[i],
        );
      }
    } catch (e) {
      print('Error scheduling medication notifications: $e');
      rethrow;
    }
  }

  /// Cancels all notifications for a specific medication
  Future<void> cancelMedicationNotifications(String medicationId) async {
    // Cancel up to 10 possible time slots for this medication
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(medicationId, i);
      await cancelNotification(notificationId);
    }
  }

  /// Generates a unique notification ID based on medication ID and time slot
  int _generateNotificationId(String medicationId, int timeSlot) {
    // Create a simple hash-based ID
    return (medicationId.hashCode + timeSlot).abs() % 2147483647;
  }

  /// Cancels a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return false;
      }
    }
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? enabled = await androidImplementation.areNotificationsEnabled();
      return enabled ?? false;
    }
    
    return true; // Assume enabled for other platforms
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final bool? result = await androidImplementation.requestNotificationsPermission();
        final bool? exactAlarmResult = await androidImplementation.requestExactAlarmsPermission();
        return (result ?? false) && (exactAlarmResult ?? false);
      }
      
      return true; // Assume permissions granted for other platforms
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Calculates the next instance of a specific time.
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
        0, // Seconds are 0 as TimeOfDay doesn't include them.
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    } catch (e) {
      print('Error calculating next instance of time: $e');
      // Fallback to a basic DateTime if timezone fails
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      // Convert to TZDateTime using the local timezone
      return tz.TZDateTime.from(scheduledDate, tz.local);
    }
  }
}
