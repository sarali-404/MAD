import 'package:flutter/material.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/profile_page.dart'; // Import Profile Page

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
    'assets/images/seed_paddy.png',
    'assets/images/fertilizer.png',
    'assets/images/seed_paddy.png',
    'assets/images/fertilizer.png',
    'assets/images/seed_paddy.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F7755),
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                thumbnails[selectedThumbnailIndex],
                height: 250,
                fit: BoxFit.cover,
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
                                ? const Color(0xFF6F7755)
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
                color: Color(0xFF6F7755),
              ),
            ),
            const SizedBox(height: 10),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F7755),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
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
                style: TextStyle(color: Colors.white, fontSize: 16),
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
