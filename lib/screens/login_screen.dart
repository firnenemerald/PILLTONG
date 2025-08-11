import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A screen that provides a user interface for login and registration.
///
/// This screen includes text fields for email and password, along with
/// buttons for logging in and registering a new user using Firebase Authentication.
class LoginScreen extends StatefulWidget {
  /// Creates a const instance of [LoginScreen].
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State to manage loading indicator
  bool _isLoading = false;

  /// Handles user registration with email and password.
  Future<void> _registerUser() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Handle successful registration
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors and display them to the user
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'An error occurred: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handles user login with email and password.
  Future<void> _loginUser() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in user with email and password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Handle successful login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors and display them to the user
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Body of the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            // Prevents overflow when keyboard appears
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Email Text Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0), // Spacer

                // Password Text Field
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hides the entered text
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0), // Spacer

                // Show a loading indicator or the buttons
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Login Button
                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            )),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 12.0), // Spacer

                      // Register Button
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            )),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
