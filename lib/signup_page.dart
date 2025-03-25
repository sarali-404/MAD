import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String userType = '';

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
              children: [
                const SizedBox(height: 30),

                // Welcome Text
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Sign Up Subtext
                const Text(
                  'Sign Up for the AgroLink',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // Username
                _buildTextField('Enter a username'),
                const SizedBox(height: 15),

                // Email
                _buildTextField('Enter your email'),
                const SizedBox(height: 15),

                // Mobile Number
                _buildTextField('Enter your mobile number'),
                const SizedBox(height: 15),

                // Password
                _buildTextField('Enter a password', obscureText: true),
                const SizedBox(height: 15),

                // Confirm Password
                _buildTextField('Confirm password', obscureText: true),
                const SizedBox(height: 25),

                // Choose Role Section
                const Text(
                  'I would like to join as a',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Seller / Farmer Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUserTypeButton('Seller'),
                    const SizedBox(width: 10),
                    _buildUserTypeButton('Farmer'),
                  ],
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3E597), // Matches image button color
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (userType.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a role to proceed."),
                        ),
                      );
                      return;
                    }
                    Navigator.pushReplacementNamed(context, '/signup_successful');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

  // Build Text Fields
  Widget _buildTextField(String hint, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF3E8), // Matches the image's input box color
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  // Build User Type Buttons (Seller / Farmer)
  Widget _buildUserTypeButton(String type) {
    bool isSelected = userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            userType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD3E597) : const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
