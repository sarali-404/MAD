import 'package:flutter/material.dart';
import 'package:Farmingapp/chat_page.dart'; // Import Chat Page
import 'package:Farmingapp/seller_dashboard.dart'; // Import Seller Dashboard

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ Scrollable Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Profile Image & Name
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/3d_avatar_12.png'),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sarali Balasinghe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'I have the best fertilizers for vegetables',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Contact Information
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF0C0000)),
                  title: const Text(
                    'Kottawa',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF0C0000)),
                  title: const Text(
                    '0766975113',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF0C0000)),
                  title: const Text(
                    'sara@gmail.com',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ Edit Profile Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E597),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(150, 40),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Divider Line
            const Divider(
              thickness: 1,
              color: Colors.black,
            ),
            const SizedBox(height: 10),

            // ✅ My Products Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6D5C7),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerDashboard()),
                );
              },
              child: const Text(
                'My products',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Updated Bottom Navigation Bar with Text Under Icons
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507), // Background Color Added
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // ✅ Added Text Label
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'), // ✅ Added Text Label
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // ✅ Added Text Label
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on Profile Page
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerDashboard()),
            );
          }
        },
      ),
    );
  }
}
