import 'package:flutter/material.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';

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

  final List<String> thumbnails = [
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
    'assets/fertilizer1.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar Updated
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Product Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // ✅ Scrollable Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Main Product Image
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

            // ✅ Thumbnail Selector
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

            // ✅ Product Name & Price
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

            // ✅ Product Description
            const Text(
              'The best quality Seed Paddy.\n\nEros, parturient sit posuere amet. Sed dignissim enim nulla egestas vitae id augue eleifend. Nam commodo scelerisque enim integer risus, non ...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Contact Details
            const Text(
              'Contact the seller: 0712345678',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Stock & Quantity Selector
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

            // ✅ Add to Cart Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E597),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: const Text(
                'ADD TO CART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      // ✅ Updated Bottom Navigation Bar with Labels
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          }
        },
      ),
    );
  }
}
