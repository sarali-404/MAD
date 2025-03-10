import 'package:flutter/material.dart';
import 'package:Farmingapp/loarding_page.dart';
import 'package:Farmingapp/welcome_page.dart';
import 'package:Farmingapp/login_page.dart';
import 'package:Farmingapp/signup_page.dart';
import 'package:Farmingapp/signup_successful_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:Farmingapp/product_details_page.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/profile_page.dart';          // Import Profile Page
import 'package:Farmingapp/editprofilepage.dart';       // Import Edit Profile Page
import 'package:Farmingapp/seller_dashboard.dart';      // Import Seller Dashboard
import 'package:Farmingapp/seller_profile_page.dart';   // Import Seller Profile Page
import 'package:Farmingapp/add_product_page.dart';  // Import Add New Product Page
import 'package:Farmingapp/chat_page.dart';
import 'package:Farmingapp/chat_page_2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farming App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6F7755),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6F7755),
          secondary: const Color(0xFFD6D5C7),
        ),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6F7755),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),  // Fixed bodyMedium usage
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6F7755),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingPage(),
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/signup_successful': (context) => const SignUpSuccessfulPage(),
        '/farmer_dashboard': (context) => const FarmerDashboard(),
        '/cart': (context) => const CartPage(),
        '/product_details': (context) => const ProductDetailsPage(
          name: 'Seed Paddy',
          price: 'Rs. 500.00',
          image: 'assets/images/seed_paddy.png',
        ),
        '/profile': (context) => const ProfilePage(),              // Profile Page Route
        '/edit_profile': (context) => const EditProfilePage(),      // Edit Profile Page Route
        '/seller_dashboard': (context) => const SellerDashboard(),  // Seller Dashboard Route
        '/seller_profile': (context) => const SellerProfilePage(),  // Seller Profile Page Route
        '/add_new_product': (context) => const AddProductPage(), // Add New Product Page Route
        '/chat_page_2': (context) => const ChatDetailPage(),

      },
    );
  }
}
