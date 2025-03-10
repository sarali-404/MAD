import 'package:flutter/material.dart';
import 'package:Farmingapp/farmer_dashboard.dart';  // Import Farmer Dashboard
import 'package:Farmingapp/seller_dashboard.dart';  // Import Seller Dashboard

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome back!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F7755),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Log in to your account",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // Username TextField
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD6D5C7),
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
                fillColor: const Color(0xFFD6D5C7),
                hintText: "Enter your Password",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
            const SizedBox(height: 30),

            // Log in as Farmer Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F7755),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Navigate to Farmer Dashboard
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FarmerDashboard()),
                );
              },
              child: const Text(
                "Log in as Farmer",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),

            // Log in as Seller Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6D5C7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Navigate to Seller Dashboard
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerDashboard()),
                );
              },
              child: const Text(
                "Log in as Seller",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Forgot Password Text
            TextButton(
              onPressed: () {
                // Handle Forgot Password
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFF6F7755),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
