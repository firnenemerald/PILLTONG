import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilltongapp/screens/main_scaffold.dart';
import 'package:pilltongapp/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If we're still waiting for the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, go to main scaffold (home with tabs)
        if (snapshot.hasData) {
          return const MainScaffold();
        }
        
        // If user is not logged in, go to login screen
        return const LoginScreen();
      },
    );
  }
}
