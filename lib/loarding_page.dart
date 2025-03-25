import 'package:flutter/material.dart';
import 'package:Farmingapp/welcome_page.dart';  // Ensure WelcomePage exists

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to WelcomePage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF592507),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB9B089),
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.png', // Ensure the asset is correctly added
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust image fit
                ),
              ),
            ),
            const SizedBox(height: 20), // Correctly placed SizedBox
            const Text(
              "AgroLink",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
