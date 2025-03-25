import 'package:flutter/material.dart';
import 'package:Farmingapp/profile_page.dart'; // Import Profile Page

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Seed Paddy',
      'price': 500.00,
      'image': 'assets/images/seed_paddy.png',
      'quantity': 2,
    },
    {
      'name': 'Seed Paddy',
      'price': 500.00,
      'image': 'assets/images/seed_paddy.png',
      'quantity': 2,
    },
    {
      'name': 'Seed Paddy',
      'price': 500.00,
      'image': 'assets/images/seed_paddy.png',
      'quantity': 2,
    },
    {
      'name': 'Seed Paddy',
      'price': 500.00,
      'image': 'assets/images/seed_paddy.png',
      'quantity': 2,
    },
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F7755),
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    color: const Color(0xFFD6D5C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product Image
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

                          // Product Details
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
                                    color: Color(0xFF6F7755),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete Button
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
            const SizedBox(height: 10),

            // Total Price
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F7755),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Checkout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F7755),
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
        ],
        selectedItemColor: const Color(0xFF6F7755),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}
