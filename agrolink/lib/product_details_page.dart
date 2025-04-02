import 'package:flutter/material.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Farmingapp/chat_detail_page.dart';
import 'package:Farmingapp/chat_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;

  const ProductDetailsPage({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  int selectedThumbnailIndex = 0;
  bool _isAddingToCart = false;

  final List<String> thumbnails = [
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
  ];

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('Please log in to add items to cart', isError: true);
        return;
      }
      
      final cartItem = {
        'productId': widget.name,
        'name': widget.name,
        'price': double.parse(widget.price.replaceAll('Rs. ', '').replaceAll(',', '')),
        'quantity': quantity,
        'image': widget.image,
        'addedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add(cartItem);
      
      _showMessage('Added to cart successfully!');
      
      setState(() {
        quantity = 1;
      });
    } catch (e) {
      print('Error adding to cart: $e');
      _showMessage('Failed to add to cart: $e', isError: true);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }
  
  Future<void> _createChatWithSeller() async {
    setState(() {
      _isAddingToCart = true; // Reuse loading state
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('Please log in to chat with the seller', isError: true);
        setState(() {
          _isAddingToCart = false;
        });
        return;
      }
      
      // For demo purposes, we'll use a fixed seller ID
      // In a real app, you'd get this from the product data
      const sellerId = "seller123"; // Replace with actual seller ID from product data
      
      // Check if a chat already exists
      final existingChatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();
      
      String chatId = '';
      
      for (var doc in existingChatsQuery.docs) {
        final participants = doc.data()['participants'] as List<dynamic>;
        if (participants.contains(sellerId)) {
          chatId = doc.id;
          print('Found existing chat: $chatId');
          break;
        }
      }
      
      // If no chat exists, create a new one
      if (chatId.isEmpty) {
        print('Creating new chat...');
        final newChatRef = FirebaseFirestore.instance.collection('chats').doc();
        
        await newChatRef.set({
          'participants': [user.uid, sellerId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessage': 'New conversation started', // Add initial message text
          'lastSenderId': user.uid, // Set the sender
        });
        
        // Also add an initial message to the chat
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(newChatRef.id)
            .collection('messages')
            .add({
              'text': 'Hi, I\'m interested in this product.',
              'senderId': user.uid,
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
              'isVoice': false,
              'delivered': true,
            });
        
        print('New chat created with ID: ${newChatRef.id}');
        chatId = newChatRef.id;
      }
      
      // Navigate to the chat detail page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: chatId,
              otherUserId: sellerId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating chat: $e');
      _showMessage('Failed to start chat: $e', isError: true);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
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
        centerTitle: true,
        title: const Text(
          'Product Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  thumbnails[selectedThumbnailIndex],
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: thumbnails.asMap().entries.map((entry) {
                  int index = entry.key;
                  String thumb = entry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedThumbnailIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedThumbnailIndex == index
                                ? const Color(0xFF8C624A)
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          thumb,
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C624A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            const Text(
              'The best quality Seed Paddy.\n\nEros, parturient sit posuere amet. Sed dignissim enim nulla egestas vitae id augue eleifend. Nam commodo scelerisque enim integer risus, non ...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Contact the seller: 0712345678',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock: 32',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () {
                              setState(() {
                                quantity--;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Add to Cart Button - Enhanced with icon
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ADD TO CART',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3E597),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isAddingToCart ? null : _addToCart,
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Message Seller Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.chat_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'CHAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C624A),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      _createChatWithSeller();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
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
