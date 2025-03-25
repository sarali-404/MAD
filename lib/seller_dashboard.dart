import 'package:flutter/material.dart';
import 'package:Farmingapp/seller_profile_page.dart'; // Import Seller Profile Page
import 'package:Farmingapp/chat_page.dart';          // Import Chat Page
import 'package:Farmingapp/welcome_page.dart';      // Import Welcome Page
import 'package:Farmingapp/add_product_page.dart';  // Import Add Product Page

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Seed Paddy',
        'description': 'The best Seed paddy',
        'price': 500.00,
        'image': 'assets/image2.png',
      },
      {
        'name': 'Organic Fertilizer',
        'description': 'Natural organic fertilizers',
        'price': 900.00,
        'image': 'assets/image2.png',
      },
      {
        'name': 'Maize Seeds',
        'description': 'High-quality maize seeds',
        'price': 600.00,
        'image': 'assets/image2.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        centerTitle: true,
        title: const Text(
          'My Products',  // ✅ AppBar Title
          style: TextStyle(
            fontSize: 22,  // ✅ Manually Set Font Size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    color: const Color(0xFFD9DFC7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              product['image'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // ✅ Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Rs. ${product['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✅ Edit and Delete Buttons
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6BAC36),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // Handle Edit Product
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // Handle Delete Product
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ✅ Restored "Add New Product" Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD3E597),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductPage()),
                  );
                },
                child: const Text(
                  'Add New Product',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Updated Bottom Navigation Bar with Leave Button
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507), // Background Color Added
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app), // ✅ Changed to Leave Icon
            label: 'Leave',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomePage()),
            );
          }
        },
      ),
    );
  }
}
