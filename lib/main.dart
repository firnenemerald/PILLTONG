import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pilltongapp/firebase_options.dart';
import 'package:pilltongapp/screens/splash_screen.dart';
import 'package:pilltongapp/services/notification_service.dart';
import 'package:pilltongapp/services/medication_service.dart';

void main() async {
  try {
    // Ensure Flutter is initialized.
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    // Initialize Firebase.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize notifications.
    try {
      await NotificationService().initialize();
      print('Notification service initialized');
      
      // Reschedule all notifications in case the app was updated or restarted
      try {
        await MedicationService().rescheduleAllNotifications();
        print('Medication notifications rescheduled');
      } catch (e) {
        print('Failed to reschedule notifications: $e');
        // Don't prevent app from starting if rescheduling fails
      }
    } catch (e) {
      print('Failed to initialize notifications: $e');
      // Continue even if notifications fail
    }

    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    // Run the app anyway, Firebase might still work
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PilltongApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Start with the splash screen.
      home: const SplashScreen(),
    );
  }
}
