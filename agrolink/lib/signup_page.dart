import 'package:Farmingapp/firebase_options.dart';
import 'package:Farmingapp/signup_successful_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'dart:async';
import 'firebase_service.dart';
import 'package:flutter/foundation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _selectedUserType = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F7755),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started with AgroLink',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    } else if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Mobile Field
                _buildTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  prefixIcon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // User Type Selection
                const Text(
                  'I would like to join as a:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // User Type Selection Buttons
                Row(
                  children: [
                    _buildUserTypeButton('Farmer'),
                    const SizedBox(width: 16),
                    _buildUserTypeButton('Seller'),
                  ],
                ),
                if (_selectedUserType.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      'Please select a role',
                      style: TextStyle(
                        color: _isLoading ? Colors.transparent : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                
                // Sign Up Button
                _buildSignUpButton(),
                const SizedBox(height: 24),
                
                // Login Option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF6F7755),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF6F7755)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFF3E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6F7755)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(String type) {
    bool isSelected = _selectedUserType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedUserType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD3E597) : const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(10),
            border: isSelected 
              ? Border.all(color: const Color(0xFF6F7755), width: 2)
              : null,
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6F7755) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD3E597),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: const Color(0xFF6F7755),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F7755)),
              strokeWidth: 3,
            )
          : const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F7755),
              ),
            ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if user type is selected
    if (_selectedUserType.isEmpty) {
      setState(() {}); // Trigger rebuild to show error message
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('🔍 DEBUG: Starting signup with email: ${_emailController.text.trim()}');
      
      // Add a small delay to avoid potential rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Step 1: Create auth user WITHOUT any additional operations
      // This simple approach avoids the PigeonUserDetails error
      User? newUser;
      
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        newUser = credential.user;
        print('✅ AUTH: User created successfully with UID: ${newUser?.uid}');
      } catch (authError) {
        print('❌ AUTH ERROR: ${authError.toString()}');
        
        // Handle specific Firebase auth errors with user-friendly messages
        String errorMsg = 'Sign up failed. Please try again later.';
        
        if (authError is FirebaseAuthException) {
          switch (authError.code) {
            case 'email-already-in-use':
              errorMsg = 'This email is already registered. Please try logging in instead.';
              break;
            case 'invalid-email':
              errorMsg = 'Please enter a valid email address.';
              break;
            case 'operation-not-allowed':
              errorMsg = 'Email/password sign up is not enabled. Please contact support.';
              break;
            case 'weak-password':
              errorMsg = 'Password is too weak. Please use at least 6 characters.';
              break;
            case 'network-request-failed':
              errorMsg = 'Network error. Please check your internet connection.';
              break;
            default:
              errorMsg = 'Error: ${authError.message ?? authError.code}';
          }
        }
        
        _showErrorSnackBar(errorMsg);
        setState(() { _isLoading = false; });
        return;
      }
      
      // Safety check to ensure we have a user
      if (newUser == null) {
        print('❌ AUTH: User creation succeeded but returned null user');
        _showErrorSnackBar('Sign up failed. Please try again later.');
        setState(() { _isLoading = false; });
        return;
      }
      
      // Step 2: Create Firestore profile - allow this to fail gracefully
      bool profileCreated = false;
      
      try {
        print('🔍 DEBUG: Creating Firestore profile for user: ${newUser.uid}');
        
        final userData = {
          'uid': newUser.uid,
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'phoneNumber': _mobileController.text.trim(),
          'userType': _selectedUserType,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Attempt to set user data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set(userData);
        
        profileCreated = true;
        print('✅ FIRESTORE: User profile created successfully');
      } catch (firestoreError) {
        print('⚠️ FIRESTORE ERROR: ${firestoreError.toString()}');
        
        // Don't stop the sign-up process if profile creation fails
        // Just show a warning but continue with success
        _showWarningSnackBar(
          'Account created but there was an issue setting up your profile. '
          'Some features may be limited until you update your profile.'
        );
      }
      
      // Complete the signup process
      print('✅ SIGNUP COMPLETE: Auth: ✓  |  Profile: ${profileCreated ? '✓' : '✗'}');
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signup_successful');
      }
    } catch (e) {
      print('❌ UNEXPECTED ERROR: ${e.toString()}');
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkFirebaseConnection() async {
    try {
      // Test Firebase Auth connection
      await FirebaseAuth.instance.app.options;
      print('✅ Firebase Auth connection successful');
      
      // Test Firestore connection with a simple read
      await FirebaseFirestore.instance.collection('test_read')
          .limit(1).get()
          .timeout(const Duration(seconds: 3));
      print('✅ Firestore connection successful');
      
      return true;
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
      return false;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email address is already in use';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        case 'invalid-email':
          return 'The email address is not valid';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';
        default:
          return error.message ?? 'An unknown error occurred';
      }
    }
    return error.toString();
  }
}
