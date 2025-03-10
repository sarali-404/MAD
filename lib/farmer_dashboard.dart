import 'package:flutter/material.dart';
import 'package:Farmingapp/product_details_page.dart';
import 'package:Farmingapp/profile_page.dart'; // Import Profile Page

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  String selectedCategory = 'All';
  String selectedSubCategory = '';

  final Map<String, List<String>> subCategories = {
    'All': [],
    'Seeds': ['Paddy', 'Maize', 'Vegetables', 'Fruits'],
    'Fertilizers': ['Organic', 'Chemical'],
  };

  final Map<String, List<Map<String, String>>> productData = {
    'All': [
      {'name': 'Seed Paddy', 'price': 'Rs. 500.00', 'image': 'assets/images/seed_paddy.png'},
      {'name': 'Fruit & Flower Fertilizer', 'price': 'Rs. 900.00', 'image': 'assets/images/fertilizer.png'},
    ],
    'Paddy': [
      {'name': 'Seed Paddy', 'price': 'Rs. 500.00', 'image': 'assets/images/seed_paddy.png'},
    ],
    'Maize': [
      {'name': 'Maize Seeds', 'price': 'Rs. 600.00', 'image': 'assets/images/seed_paddy.png'},
    ],
    'Vegetables': [
      {'name': 'Vegetable Seeds', 'price': 'Rs. 800.00', 'image': 'assets/images/seed_paddy.png'},
    ],
    'Fruits': [
      {'name': 'Fruit Seeds', 'price': 'Rs. 700.00', 'image': 'assets/images/seed_paddy.png'},
    ],
    'Organic': [
      {'name': 'Organic Fertilizer', 'price': 'Rs. 1200.00', 'image': 'assets/images/fertilizer.png'},
    ],
    'Chemical': [
      {'name': 'Chemical Fertilizer', 'price': 'Rs. 1500.00', 'image': 'assets/images/fertilizer.png'},
    ],
  };

  List<Map<String, String>> getFilteredProducts() {
    if (selectedSubCategory.isNotEmpty) {
      return productData[selectedSubCategory] ?? [];
    }
    return productData[selectedCategory] ?? productData['All']!;
  }

  @override
  Widget build(BuildContext context) {
    final products = getFilteredProducts();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F7755),
        title: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search products',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (category) {
              setState(() {
                selectedCategory = category;
                selectedSubCategory = '';
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Seeds', child: Text('Seeds')),
              const PopupMenuItem(value: 'Fertilizers', child: Text('Fertilizers')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedCategory != 'All')
              DropdownButton<String>(
                isExpanded: true,
                value: selectedSubCategory.isNotEmpty ? selectedSubCategory : null,
                hint: Text('Select $selectedCategory type'),
                items: subCategories[selectedCategory]!
                    .map((subCat) => DropdownMenuItem(
                  value: subCat,
                  child: Text(subCat),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value!;
                  });
                },
              ),
            const SizedBox(height: 10),
            const Text(
              'Products for you',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: GridView.builder(
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
                      color: const Color(0xFFD6D5C7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            product['image']!,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'The best quality',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  product['price']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
