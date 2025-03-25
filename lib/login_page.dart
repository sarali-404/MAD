import 'package:flutter/material.dart';
import 'package:Farmingapp/farmer_dashboard.dart';  // Import Farmer Dashboard
import 'package:Farmingapp/seller_dashboard.dart';  // Import Seller Dashboard
import 'package:Farmingapp/signup_page.dart';  // Import SignUpPage

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  String selectedRole = "Select Role";
  bool isLoginPressed = false;  // Track login button press

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

                // Username TextField
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFEDDC),
                    hintText: "Enter your Username",
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

                // Role Selection Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDDC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                      items: ["Select Role", "Farmer", "Seller"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoginPressed ? Colors.green : const Color(0xFFD3E597),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isLoginPressed = true;
                    });

                    // Navigate based on role selection
                    if (selectedRole == "Farmer") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const FarmerDashboard()),
                      ).then((_) {
                        setState(() {
                          isLoginPressed = false;
                        });
                      });
                    } else if (selectedRole == "Seller") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SellerDashboard()),
                      ).then((_) {
                        setState(() {
                          isLoginPressed = false;
                        });
                      });
                    } else {
                      // Show error if role is not selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a role to proceed."),
                        ),
                      );
                      setState(() {
                        isLoginPressed = false;
                      });
                    }
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
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
                        // Navigate to Sign Up Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
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
