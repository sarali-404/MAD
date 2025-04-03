import 'package:flutter/material.dart';
import 'package:Farmingapp/product_details_page.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/chat_page.dart'; // Add import for chat page
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Farmingapp/services/notifications_service.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  bool _isLoading = true;
  List<DocumentSnapshot> _products = [];
  String _selectedCategory = 'All';
  String _userName = 'Farmer';
  bool _showNewProductsNotification = false;

  // New variables for dashboard stats
  int _totalProducts = 0;
  Map<String, int> _productsByCategory = {};
  List<String> _categories = ['All', 'Seeds', 'Fertilizers', 'Tools'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadProducts();
    _checkNewProductNotifications();
  }

  // Load user information
  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _userName = doc.data()?['username'] ?? doc.data()?['name'] ?? 'Farmer';
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📦 Attempting to load products...');

      // Simplified query to ensure ALL products are loaded
      Query query = FirebaseFirestore.instance.collection('products');

      // Filter out hidden products
      query = query.where('isHidden', isEqualTo: false);

      // Add category filter if not "All"
      if (_selectedCategory != 'All') {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      print('🔍 Executing query: collection=products, category=${_selectedCategory}');

      // Execute the query
      final querySnapshot = await query.get();
      print('📊 Found ${querySnapshot.docs.length} total products');

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No products found with query');
      } else {
        // Print some sample product data for debugging
        final sample = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('📋 Sample product: ${sample['name']} (${sample['category']}) by seller: ${sample['sellerId']}');
      }

      // Process results for display
      setState(() {
        _products = querySnapshot.docs;
        _isLoading = false;
        _totalProducts = querySnapshot.docs.length;

        // Recalculate category counts
        Map<String, int> categoryCount = {};
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] as String? ?? 'Other';
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
        _productsByCategory = categoryCount;
      });
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _isLoading = false;
        _products = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products. Please try again.')),
      );
    }
  }

  Future<void> _checkNewProductNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final newProductNotifications = userDoc.data()?['newProductNotifications'] ?? 0;
        setState(() {
          _showNewProductsNotification = newProductNotifications > 0;
        });
      }
    } catch (e) {
      print('Error checking new product notifications: $e');
    }
  }

  Future<void> _resetNewProductNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await NotificationsService.markProductNotificationsAsRead(user.uid);
      setState(() {
        _showNewProductsNotification = false;
      });
    } catch (e) {
      print('Error resetting product notifications: $e');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              try {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;

                // Navigate to welcome page after logout
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (route) => false
                );
              } catch (e) {
                print('Error signing out: $e');
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        title: Text(
          'Welcome, $_userName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // Notification icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  // When clicked, reset the notification indicator
                  _resetNewProductNotifications();

                  // Show notification dialog
                  _showNotificationDialog();
                },
              ),
              if (_showNewProductsNotification)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Logout icon
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8C624A)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              color: const Color(0xFF8C624A),
              child: CustomScrollView(
                slivers: [
                  // Dashboard stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F7755),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats cards in a row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildStatCard(
                                  title: 'Products',
                                  value: _totalProducts.toString(),
                                  icon: Icons.inventory_2_outlined,
                                  color: Colors.blueAccent,
                                ),
                                _buildStatCard(
                                  title: 'Seeds',
                                  value: (_productsByCategory['Seeds'] ?? 0).toString(),
                                  icon: Icons.grass_outlined,
                                  color: Colors.green,
                                ),
                                _buildStatCard(
                                  title: 'Fertilizers',
                                  value: (_productsByCategory['Fertilizers'] ?? 0).toString(),
                                  icon: Icons.science_outlined,
                                  color: Colors.orangeAccent,
                                ),
                                _buildStatCard(
                                  title: 'Tools',
                                  value: (_productsByCategory['Tools'] ?? 0).toString(),
                                  icon: Icons.build_outlined,
                                  color: Colors.purpleAccent,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Category filters with better design
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F7755),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Category filter chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryChip(_categories[index]),
                          );
                        },
                      ),
                    ),
                  ),

                  // Products grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _products.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No ${_selectedCategory.toLowerCase()} products found',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75, // Adjusted aspect ratio since we removed the button
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final doc = _products[index];
                                final product = doc.data() as Map<String, dynamic>;

                                return _buildProductCard(
                                  product['name'] as String,
                                  product['price'] as double,
                                  product['image'] as String,
                                  product['category'] as String? ?? 'Unknown',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsPage(
                                          name: product['name'] as String,
                                          price: 'Rs. ${product['price']}',
                                          image: product['image'] as String,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: _products.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),

      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: NotificationsService.getUserNotifications(FirebaseAuth.instance.currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          // Default to 0 if no data
          int messageCount = 0;

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData != null) {
              messageCount = (userData['unreadMessages'] as int?) ?? 0;
            }
          }

          return BottomNavigationBar(
            backgroundColor: const Color(0xFF592507),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            currentIndex: 0, // Dashboard is selected
            type: BottomNavigationBarType.fixed, // Required for more than 3 items
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              // Messages item with notification badge
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    if (messageCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            messageCount > 9 ? '9+' : messageCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                // Already on Dashboard
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
          );
        }
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('notifications')
                .where('type', isEqualTo: 'new_product')
                .orderBy('timestamp', descending: true)
                .limit(10)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No new notifications'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final notification = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final timestamp = notification['timestamp'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? _formatTimestamp(timestamp.toDate())
                      : 'Recently';

                  return ListTile(
                    leading: const Icon(Icons.new_releases, color: Color(0xFF8C624A)),
                    title: Text('New Product: ${notification['productName']}'),
                    subtitle: Text('Added $formattedDate'),
                    onTap: () {
                      // Navigate to product details
                      Navigator.pop(context);
                      // You could implement navigation to the product detail page here
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Stat card widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Text(category),
      selected: isSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFFD3E597),
      checkmarkColor: const Color(0xFF6F7755),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6F7755) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      elevation: isSelected ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
        _loadProducts();
      },
    );
  }

  Widget _buildProductCard(
    String name,
    double price,
    String image,
    String category,
    VoidCallback onTap
  ) {
    // Get image widget with better error handling
    Widget getImageWidget() {
      try {
        if (image.isEmpty) {
          return Container(
            height: 130,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          );
        } else if (image.startsWith('assets/')) {
          // Handle asset image
          return Image.asset(
            image,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              print('⚠️ Failed to load asset image: $image');
              return Container(
                height: 130,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              );
            },
          );
        } else {
          // Assume it's a network URL
          return Image.network(
            image,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              print('⚠️ Failed to load network image: $image');
              return Container(
                height: 130,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              );
            },
          );
        }
      } catch (e) {
        print('❌ Error rendering image "$image": $e');
        return Container(
          height: 130,
          color: Colors.grey[300],
          child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
        );
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with category tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: getImageWidget(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details - Updated without Add to Cart button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Price and Stock info in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        'Rs. ${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C624A),
                        ),
                      ),

                      // Stock pill indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Stock: 10+',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
