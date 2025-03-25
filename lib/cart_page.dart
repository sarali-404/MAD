import 'package:flutter/material.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Seed Paddy', 'price': 500.00, 'image': 'assets/fertilizer1.png', 'quantity': 2},
    {'name': 'Seed Paddy', 'price': 500.00, 'image': 'assets/fertilizer1.png', 'quantity': 2},
    {'name': 'Seed Paddy', 'price': 500.00, 'image': 'assets/fertilizer1.png', 'quantity': 2},
    {'name': 'Seed Paddy', 'price': 500.00, 'image': 'assets/fertilizer1.png', 'quantity': 2},
  ];

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double getTotalPrice() {
    return cartItems.fold(0, (total, item) => total + item['price'] * item['quantity']);
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
          'Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ✅ Column to Ensure Bottom Nav Bar is Always Visible
      body: Column(
        children: [
          // ✅ Scrollable Cart Items
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  color: const Color(0xFFFFF1E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ✅ Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            item['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
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
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Quantity: ${item['quantity']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C624A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Total Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C624A),
                ),
              ),
            ),
          ),

          // ✅ Checkout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Handle Checkout
              },
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      // ✅ Updated Bottom Navigation Bar with Labels
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 2, // Set Active Tab to 'Cart'
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // ✅ Text Added
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // ✅ Text Added
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart', // ✅ Text Added
          ),
        ],
        onTap: (index) {
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
          }
        },
      ),
    );
  }
}
