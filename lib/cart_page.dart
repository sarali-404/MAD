import 'package:flutter/material.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:Farmingapp/chat_page.dart'; // Add missing import for ChatPage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<DocumentSnapshot> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }
  
  // Load cart items from Firestore
  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _cartItems = [];
        });
        return;
      }
      
      // Get cart items
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .orderBy('addedAt', descending: true)
          .get();
      
      setState(() {
        _cartItems = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() {
        _isLoading = false;
      });
      _showMessage('Failed to load cart items', isError: true);
    }
  }
  
  // Update item quantity
  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeItem(itemId);
      return;
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId)
          .update({'quantity': newQuantity});
      
      _loadCartItems();
    } catch (e) {
      print('Error updating quantity: $e');
      _showMessage('Failed to update quantity', isError: true);
    }
  }
  
  // Remove item from cart
  Future<void> _removeItem(String itemId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId)
          .delete();
      
      _showMessage('Item removed from cart');
      _loadCartItems();
    } catch (e) {
      print('Error removing item: $e');
      _showMessage('Failed to remove item', isError: true);
    }
  }
  
  // Calculate total price
  double _getTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      final data = item.data() as Map<String, dynamic>;
      total += (data['price'] as num) * (data['quantity'] as num);
    }
    return total;
  }
  
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        title: const Text(
          'Saved Items',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Your saved items list is empty!',
                            style: TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final doc = _cartItems[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final quantity = data['quantity'] as int;
                            final price = data['price'] as double;
                            
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
                                    // Product image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        data['image'] as String,
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
                                    
                                    // Product details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] as String,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          
                                          // Price and quantity selector
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rs. ${price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF8C624A),
                                                ),
                                              ),
                                              
                                              // Quantity controls
                                              Row(
                                                children: [
                                                  IconButton(
                                                    iconSize: 20,
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    icon: const Icon(Icons.remove_circle_outline),
                                                    onPressed: () => _updateQuantity(doc.id, quantity - 1),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    iconSize: 20,
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    icon: const Icon(Icons.add_circle_outline),
                                                    onPressed: () => _updateQuantity(doc.id, quantity + 1),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(doc.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Replace checkout section with info section
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, 
                            color: const Color(0xFF6F7755),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Save your favorite products for future reference',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6F7755),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'To purchase items, please contact the supplier directly through the chat option on the product details page.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      
      // Bottom navigation - Updated with cart item selected
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 1, // Changed from 0 to 1 to highlight the Cart tab
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmerDashboard()),
            );
          } else if (index == 1) {
            // Already on Cart page
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}
