import 'package:flutter/material.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/edit_profile_page.dart'; // ✅ Corrected Import

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerDashboard()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      // ✅ Profile Details
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Profile Image & Name Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300], // Placeholder color
                              backgroundImage: const AssetImage('assets/3d_avatar_12.png'),
                              onBackgroundImageError: (_, __) {
                                // ✅ Show default icon if image fails to load
                                setState(() {});
                              },
                               // ✅ Default icon if image fails
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Rahul Wijayakulathilaka',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "I'm a Rice farmer",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Information
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.black),
                        title: const Text('Kottawa'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.black),
                        title: const Text('0766975113'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.black),
                        title: const Text('Rahul@gmail.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ✅ Updated Edit Profile Button (Navigates to EditProfilePage)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3E597),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(150, 50),
                      ),
                      onPressed: () {
                        // ✅ Navigate to EditProfilePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      },
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),

                  // ✅ Divider Line
                  const Divider(
                    thickness: 1,
                    color: Colors.black,
                  ),

                  // Saved Products & Purchase History Buttons
                  const SizedBox(height: 20),
                  _buildOptionButton('Saved products', () {}),
                  const SizedBox(height: 10),
                  _buildOptionButton('Purchase history', () {}),
                ],
              ),
            ),
          ),
        ],
      ),

      // ✅ Fixed Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Helper function for buttons
  Widget _buildOptionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD6D5C7),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ✅ Updated Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF592507),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // ✅ Added Label
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // ✅ Added Label
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), // ✅ Added Label
      ],
      onTap: _onItemTapped,
    );
  }
}
