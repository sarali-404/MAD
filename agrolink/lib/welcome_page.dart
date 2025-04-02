import 'package:flutter/material.dart';
import 'package:Farmingapp/login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLoginPressed = false;
  bool isSignUpPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image2.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Connecting Farmers & Suppliers\nfor a Better Harvest.",
              style: TextStyle(
                color: Color(0xFF0C0000),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoginPressed ? Colors.green : const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  isLoginPressed = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ).then((_) {
                  setState(() {
                    isLoginPressed = false;
                  });
                });
              },
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSignUpPressed ? Colors.green : const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  isSignUpPressed = true;
                });
                Navigator.pushNamed(context, '/simple_signup').then((_) {
                  setState(() {
                    isSignUpPressed = false;
                  });
                });
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
