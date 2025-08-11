import 'package:flutter/material.dart';
import 'package:pilltongapp/screens/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // After a delay, navigate to the AuthGate.
  void _navigateToHome() async {
    print('Starting navigation timer...');
    
    try {
      // Wait for a longer duration to ensure Firebase is fully initialized
      await Future.delayed(const Duration(milliseconds: 3000));
      print('Timer completed, attempting navigation...');

      if (!mounted) {
        print('Widget not mounted, skipping navigation');
        return;
      }

      print('Widget is mounted, navigating to AuthGate...');
      
      // Use pushAndRemoveUntil to ensure clean navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false, // Remove all previous routes
      );
      
      print('Navigation successful');
    } catch (e) {
      print('Navigation error: $e');
      
      // If navigation fails, try again after a short delay
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication_liquid, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            const Text(
              'PilltongApp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
