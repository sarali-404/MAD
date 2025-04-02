import 'package:flutter/material.dart';

class SignUpSuccessfulPage extends StatelessWidget {
  const SignUpSuccessfulPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon/animation
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDF3D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF6F7755),
                  size: 80,
                ),
              ),
              const SizedBox(height: 40),
              
              // Success text
              const Text(
                'Sign Up Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F7755),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Your account has been created successfully. Welcome to AgroLink!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3E597),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Navigate to login - user will be auto logged in via AuthGate
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Continue to Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F7755),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
