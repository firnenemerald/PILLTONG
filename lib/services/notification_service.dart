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

  /// Initializes the notification service.
  ///
  /// This method sets up the timezone database, configures platform-specific
  /// settings, and requests necessary permissions.
  Future<void> initialize() async {
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
        DarwinInitializationSettings();

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
    await androidImplementation?.requestNotificationsPermission();
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
  }

  /// Cancels a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Calculates the next instance of a specific time.
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
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
  }
}
