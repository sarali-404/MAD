import 'package:flutter/material.dart';
import 'package:Farmingapp/product_details_page.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/welcome_page.dart'; // ✅ Import Welcome Page

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  String selectedCategory = 'All';
  bool isFilterOpen = false;
  bool isSortOpen = false;
  Set<int> favoriteProducts = {}; // Track favorite products

  final Map<String, List<String>> subCategories = {
    'All': [],
    'Seeds': ['Paddy', 'Maize', 'Vegetables', 'Fruits'],
    'Fertilizers': ['Organic', 'Chemical'],
  };

  final List<Map<String, dynamic>> allProducts = [
    {'name': 'Seed Paddy', 'category': 'Seeds', 'price': 'Rs. 500.00', 'image': 'assets/fertilizer1.png'},
    {'name': 'Fruit & Flower Fertilizer', 'category': 'Fertilizers', 'price': 'Rs. 900.00', 'image': 'assets/fertilizer1.png'},
    {'name': 'Maize Seeds', 'category': 'Seeds', 'price': 'Rs. 600.00', 'image': 'assets/fertilizer1.png'},
    {'name': 'Organic Fertilizer', 'category': 'Fertilizers', 'price': 'Rs. 1200.00', 'image': 'assets/fertilizer1.png'},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = selectedCategory == 'All'
        ? allProducts
        : allProducts.where((product) => product['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFilterOpen)
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                'Products for you',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

          // Show filter panel when open
          if (isFilterOpen) _buildFilterPanel(),

          // Products Section
          Expanded(child: _buildProductGrid(filteredProducts)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build AppBar with search bar, sort & filter buttons
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF8C624A),
      elevation: 0,
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE3D0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products',
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSortOpen ? Icons.close : Icons.swap_vert,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isSortOpen = !isSortOpen;
              isFilterOpen = false;
            });
          },
        ),
        IconButton(
          icon: Icon(
            isFilterOpen ? Icons.close : Icons.filter_list,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isFilterOpen = !isFilterOpen;
              isSortOpen = false;
            });
          },
        ),
      ],
    );
  }

  // Build Filter Panel (Collapsible)
  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: subCategories.keys.map((category) {
          return _buildExpandableCategory(category, subCategories[category]!);
        }).toList(),
      ),
    );
  }

  // Build Expandable Category
  Widget _buildExpandableCategory(String category, List<String> items) {
    return ExpansionTile(
      title: Text(
        category,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          title: const Text('All'),
          onTap: () {
            setState(() {
              selectedCategory = 'All';
              isFilterOpen = false;
            });
          },
        ),
        ...items.map((item) {
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                selectedCategory = category;
                isFilterOpen = false;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  // Build Product Grid
  Widget _buildProductGrid(List<Map<String, dynamic>> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  name: product['name']!,
                  price: product['price']!,
                  image: product['image']!,
                ),
              ),
            );
          },
          child: Card(
            color: const Color(0xFF592507),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      product['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEBC9A8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product['price']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEBC9A8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build Bottom Navigation Bar with Text Under Icons
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF592507),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // ✅ Text Added
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), // ✅ Text Added
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'), // ✅ Text Added
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
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        }
      },
    );
  }
}
