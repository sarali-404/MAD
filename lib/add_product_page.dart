import 'package:flutter/material.dart';
import 'package:Farmingapp/seller_profile_page.dart'; // Seller Profile Page
import 'package:Farmingapp/chat_page.dart'; // Chat Page
import 'package:Farmingapp/seller_dashboard.dart'; // Seller Dashboard

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String? selectedCategory; // Track selected category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar with Updated Font Size
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add New Product',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // ✅ Scrollable Content
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Select a category (Dropdown)
                  const Text(
                    'Select a category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        hint: const Text('Choose a category'),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 'Seeds', child: Text('Seeds')),
                          DropdownMenuItem(value: 'Fertilizers', child: Text('Fertilizers')),
                          DropdownMenuItem(value: 'Tools', child: Text('Tools')),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  _buildInputField('Product name'),
                  const SizedBox(height: 15),
                  _buildInputField('Description'),
                  const SizedBox(height: 15),
                  _buildInputField('Add more details', maxLines: 4),
                  const SizedBox(height: 15),
                  _buildInputField('Add price'),
                  const SizedBox(height: 15),
                  _buildInputField('Current stock'),
                  const SizedBox(height: 15),

                  // ✅ Add Images Section
                  const Text(
                    'Add images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _buildImagePicker(),
                      const SizedBox(width: 10),
                      _buildImagePicker(),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ✅ Upload Button (Always Visible)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Handle Upload
              },
              child: const Text(
                'Upload',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // ✅ Updated Bottom Navigation Bar with Text Labels
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507), // Background Color Added
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // ✅ Added Label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages', // ✅ Added Label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // ✅ Added Label
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerProfilePage()),
            );
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

  // ✅ Input Field Builder (with Title Above TextBox)
  Widget _buildInputField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD6D5C7),
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        ),
      ],
    );
  }

  // ✅ Image Picker Builder
  Widget _buildImagePicker() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.black54),
      ),
    );
  }
}
