import 'package:flutter/material.dart';
import 'package:Farmingapp/seller_profile_page.dart';
import 'package:Farmingapp/chat_page.dart';
import 'package:Farmingapp/seller_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Farmingapp/services/notifications_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  bool _isLoading = false;
  bool _isAddingCategory = false;
  final _newCategoryController = TextEditingController();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailsController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  // Categories - modified to allow addition of new categories
  final List<String> _categories = ['Seeds', 'Fertilizers', 'Tools', 'Equipment', 'Other'];
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }
  
  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fill all required fields', isError: true);
      return;
    }
    
    if (selectedCategory == null) {
      _showMessage('Please select a category', isError: true);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('📤 Starting product upload process...');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('You must be logged in to add products', isError: true);
        return;
      }
      
      // Get seller information for the product
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final sellerName = userDoc.data()?['username'] ?? userDoc.data()?['name'] ?? 'Unknown Seller';
      
      // Standard image path that will work across app
      const imagePath = 'assets/fertilizer1.png';
      
      // Create complete product data with all required fields
      final productData = {
        'sellerId': user.uid,
        'sellerName': sellerName,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'details': _detailsController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'category': selectedCategory,
        'image': imagePath,
        'createdAt': FieldValue.serverTimestamp(),
        'isHidden': false,
      };
      
      // Add to Firestore and get the ID
      final docRef = await FirebaseFirestore.instance
          .collection('products')
          .add(productData);
      
      // Create notification for farmers about the new product
      await NotificationsService.createProductNotification(
        docRef.id,
        _nameController.text.trim(),
        user.uid
      );
      
      _showMessage('Product added successfully!');
      
      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _detailsController.clear();
      _priceController.clear();
      _stockController.clear();
      setState(() {
        selectedCategory = null;
      });
    } catch (e) {
      print('Error adding product: $e');
      _showMessage('Failed to add product: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF6F7755),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _addNewCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        selectedCategory = newCategory;
        _isAddingCategory = false;
        _newCategoryController.clear();
      });
      
      _showMessage('Added new category: $newCategory');
    } else if (_categories.contains(newCategory)) {
      _showMessage('This category already exists', isError: true);
    } else {
      _showMessage('Please enter a category name', isError: true);
    }
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
          'Add New Product',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Product type header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF8C624A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What type of product are you adding?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: _isAddingCategory ? 100 : 50,
                      child: Column(
                        children: [
                          // Category list scrollable
                          SizedBox(
                            height: 50,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Existing categories
                                ..._categories.map((category) {
                                  final isSelected = selectedCategory == category;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = category;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFD3E597) : Colors.white,
                                          borderRadius: BorderRadius.circular(25),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFFD3E597) : Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ] : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black87,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                // Add category button - updated for better visibility
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAddingCategory = !_isAddingCategory;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _isAddingCategory 
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: _isAddingCategory 
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.white.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isAddingCategory ? Icons.close : Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          if (!_isAddingCategory) ...[
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Add New',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // New category input field
                          if (_isAddingCategory) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextField(
                                      controller: _newCategoryController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter new category',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _addNewCategory,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD3E597),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable form fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF592507),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Product Name - Modern style
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          hintText: 'Enter product name',
                          prefixIcon: const Icon(Icons.inventory, color: Color(0xFF8C624A)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description - Modern style
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of the product',
                          prefixIcon: const Icon(Icons.description, color: Color(0xFF8C624A)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Details - Modern style with multiple lines
                      TextFormField(
                        controller: _detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Additional Details',
                          hintText: 'Enter detailed product information',
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child: Icon(Icons.subject, color: Color(0xFF8C624A)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Pricing & Inventory',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF592507),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Price and Stock in Row - Modern style
                      Row(
                        children: [
                          // Price
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Price (Rs.)',
                                hintText: '0.00',
                                prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF8C624A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Stock
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Stock Qty',
                                hintText: '0',
                                prefixIcon: const Icon(Icons.inventory_2, color: Color(0xFF8C624A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Image section - Modern style
                      const Text(
                        'Product Images',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF592507),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Main image preview or picker
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Color(0xFF8C624A),
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Additional images
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Upload button - Modern style with floating effect
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3E597),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFFD3E597).withOpacity(0.5),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Upload Product',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Update bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF592507),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SellerDashboard()),
            );
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
      ),
    );
  }
}
