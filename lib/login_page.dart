import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Farmingapp/farmer_dashboard.dart';  // Import Farmer Dashboard
import 'package:Farmingapp/seller_dashboard.dart';  // Import Seller Dashboard
import 'package:Farmingapp/signup_page.dart';  // Import SignUpPage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Farmingapp/services/auth_service.dart'; // Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  Future<void> signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('Please enter both email and password');
      return;
    }

    setState(() => isLoading = true);

    try {
      print('🔄 Starting login process...');
      
      // 1. Authenticate with Firebase
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (credential.user == null) throw Exception('Login failed');
      
      print('✅ Authentication successful');

      // 2. Get user type from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      // Update user status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      final userType = userDoc.data()?['userType'] as String? ?? 'Farmer';
      print('👤 User type: $userType');

      if (mounted) {
        final route = userType == 'Seller' ? '/seller_dashboard' : '/farmer_dashboard';
        print('🚀 Navigating to: $route');
        Navigator.pushReplacementNamed(context, route);
      }

    } catch (e) {
      print('❌ Login error: $e');
      _showErrorMessage(_getFirebaseErrorMessage(e));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper method for user-friendly error messages
  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-credential':
          return 'Invalid email or password';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many login attempts. Try again later.';
        default:
          return error.message ?? 'Authentication failed';
      }
    }
    return error.toString();
  }

  // Create a basic user profile if it doesn't exist
  Future<void> _createUserProfile(String uid, String email) async {
    try {
      print('DIRECT LOGIN: Creating basic user profile for uid: $uid');
      
      final userData = {
        'uid': uid,
        'email': email,
        'username': email.split('@')[0],
        'phoneNumber': '',
        'userType': 'Farmer', // Default to Farmer
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);
      
      print('DIRECT LOGIN: Basic profile created successfully');
    } catch (e) {
      print('DIRECT LOGIN: Failed to create user profile: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Add a method to show Firebase rules guidance
  void _showFirebaseRulesMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Firebase Permissions Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your app is encountering permission errors with Firestore.'),
            SizedBox(height: 10),
            Text('To fix this, update your Firestore rules in the Firebase Console:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(
'''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId} {
      allow create: if request.auth != null;
    }
  }
}
'''
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD3E597),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: isLoading ? null : signIn,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.black),
            )
          : const Text(
              "Log In",
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
    );
  }

  @override
  void dispose() {
    // Update user's online status when leaving
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Log in to your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // Email TextField (changed from Username)
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // Add email keyboard type
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFEDDC),
                    hintText: "Enter your Email",  // Changed from Username to Email
                    prefixIcon: const Icon(Icons.email), // Add email icon
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
                const SizedBox(height: 15),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFEDDC),
                    hintText: "Enter your Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
                const SizedBox(height: 15),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        const Text(
                          "Remember Me",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgotten password?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Log In Button (Matches Welcome Page Style)
                _buildLoginButton(),
                const SizedBox(height: 30),

                // Sign Up Option (Navigate to Sign Up Page)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to SimpleSignupPage instead of SignUpPage
                        Navigator.pushNamed(context, '/simple_signup');
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
