import 'package:flutter/material.dart';
import 'package:Farmingapp/seller_profile_page.dart'; // Import Seller Profile Page
import 'package:Farmingapp/seller_dashboard.dart';  // Import Seller Dashboard

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = List.generate(
      12,
          (index) => {
        'name': 'Sarali',
        'message': 'Hi,',
        'image': 'assets/image2.png',
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // ✅ Scrollable Chat List with Search & Filters
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // ✅ Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD6D5C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search chats, accounts',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 10),
                _buildFilterChip('Unread', false),
                const SizedBox(width: 10),
                _buildFilterChip('Archived', false),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ Chat List
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color(0xFFFFEDDC),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            chat['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          chat['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          chat['message'],
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () {
                          // Navigate to chat details
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ✅ Floating Action Button for New Chats
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8C624A),
        onPressed: () {
          // Handle new chat
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // ✅ Updated Bottom Navigation Bar with Text Labels
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507), // Background Color Updated
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 1, // Highlight 'Chats' as active
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // ✅ Added Label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats', // ✅ Added Label
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
            // Stay on Chat Page
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

  // ✅ Custom Filter Chip Builder
  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF8C624A),
      backgroundColor: const Color(0xFFD6D5C7),
      onSelected: (selected) {
        // Handle chip selection
      },
    );
  }
}
