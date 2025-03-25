import 'package:flutter/material.dart';
import 'package:Farmingapp/seller_profile_page.dart'; // Import Seller Profile Page

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar Updated
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ✅ Scrollable Form
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ✅ Profile Picture with Edit Icon
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/image2.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF6F7755),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () {
                          // Handle profile picture edit
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Form Fields
            buildTextField('Name', 'Sarali Balasinghe'),
            const SizedBox(height: 15),
            buildTextField('Email / Phone number', 'sarali@gmail.com'),
            const SizedBox(height: 15),
            buildTextField('Description', 'Rice farmer'),
            const SizedBox(height: 35),
            buildTextField('Location', 'Kottawa'),
            const SizedBox(height: 30),

            // ✅ Save Changes Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Navigate to Seller Profile Page after saving changes
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerProfilePage()),
                );
              },
              child: const Text(
                'Save changes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Custom Input Field Builder
  Widget buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            filled: true,
            fillColor: const Color(0xFFFFEDDC),
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
