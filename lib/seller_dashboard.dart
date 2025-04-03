import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Farmingapp/seller_profile_page.dart';
import 'package:Farmingapp/add_product_page.dart';
import 'package:Farmingapp/chat_page.dart';
import 'package:Farmingapp/edit_product_page.dart';
import 'package:Farmingapp/services/notifications_service.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  bool _isLoading = true;
  List<DocumentSnapshot> _myProducts = [];
  String _sellerName = 'Seller';
  int _unreadMessages = 0;

  int _totalStock = 0;
  int _lowStockItems = 0;
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
    _loadMyProducts();
  }

  Future<void> _loadSellerInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _sellerName = doc.data()?['username'] ?? 'Seller';
        });
      }
    } catch (e) {
      print('Error loading seller info: $e');
    }
  }

  Future<void> _loadMyProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      int totalStock = 0;
      int lowStockItems = 0;
      double totalValue = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final stock = (data['stock'] as num).toInt();
        final price = (data['price'] as num).toDouble();

        totalStock += stock;
        if (stock < 10) lowStockItems++;
        totalValue += price * stock;
      }

      setState(() {
        _myProducts = querySnapshot.docs;
        _totalStock = totalStock;
        _lowStockItems = lowStockItems;
        _totalValue = totalValue;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
      _showMessage('Failed to load your products');
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      _showMessage('Product deleted successfully');
      _loadMyProducts();
    } catch (e) {
      print('Error deleting product: $e');
      _showMessage('Failed to delete product');
    }
  }

  Future<void> _toggleProductVisibility(String productId, Map<String, dynamic> product) async {
    try {
      bool isHidden = product['isHidden'] ?? false;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'isHidden': !isHidden});

      _showMessage(isHidden
          ? 'Product is now visible'
          : 'Product is now hidden');

      _loadMyProducts();
    } catch (e) {
      print('Error toggling product visibility: $e');
      _showMessage('Failed to update product visibility');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8C624A),
        title: Text(
          'Welcome, $_sellerName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Notification handling
            },
          ),
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
              onRefresh: _loadMyProducts,
              color: const Color(0xFF8C624A),
              child: CustomScrollView(
                slivers: [
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

                          Row(
                            children: [
                              _buildStatCard(
                                title: 'Products',
                                value: _myProducts.length.toString(),
                                icon: Icons.inventory_2_outlined,
                                color: Colors.blueAccent,
                              ),
                              _buildStatCard(
                                title: 'Total Stock',
                                value: _totalStock.toString(),
                                icon: Icons.store_outlined,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatCard(
                                title: 'Low Stock',
                                value: _lowStockItems.toString(),
                                icon: Icons.warning_amber_outlined,
                                color: Colors.orangeAccent,
                              ),
                              _buildStatCard(
                                title: 'Value',
                                value: '₹${_totalValue.toStringAsFixed(2)}',
                                icon: Icons.monetization_on_outlined,
                                color: Colors.purpleAccent,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Products',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6F7755),
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add New'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF8C624A),
                                  side: const BorderSide(color: Color(0xFF8C624A)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddProductPage(),
                                    ),
                                  ).then((_) => _loadMyProducts());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  _myProducts.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final doc = _myProducts[index];
                                final product = doc.data() as Map<String, dynamic>;

                                return _buildProductCard(doc.id, product);
                              },
                              childCount: _myProducts.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),

      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: NotificationsService.getUserNotifications(FirebaseAuth.instance.currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          int messageCount = 0;

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData != null) {
              messageCount = (userData['unreadMessages'] as int?) ?? 0;
            }
          }

          return BottomNavigationBar(
            backgroundColor: const Color(0xFF592507),
            elevation: 8,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            currentIndex: 0, // Dashboard tab selected
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
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
                // Already on Dashboard
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerProfilePage()),
                );
              }
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD3E597),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          ).then((_) => _loadMyProducts());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No products yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6F7755),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD3E597),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductPage(),
                ),
              ).then((_) => _loadMyProducts());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> product) {
    final isHidden = product['isHidden'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        product['image'] as String,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    if (isHidden)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (product['stock'] as num) < 10
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Stock: ${product['stock']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (product['stock'] as num) < 10
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${(product['price'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF8C624A),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['category'] as String? ?? 'Uncategorized',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(
                          productId: productId,
                          productData: product,
                        ),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        _loadMyProducts();
                      }
                    });
                  },
                ),
                TextButton.icon(
                  icon: Icon(
                    isHidden ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                  ),
                  label: Text(isHidden ? 'Show' : 'Hide'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    _toggleProductVisibility(productId, product);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this product?'
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          TextButton(
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteProduct(productId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;

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
}
