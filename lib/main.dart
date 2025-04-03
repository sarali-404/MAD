import 'package:Farmingapp/auth_page.dart';
import 'package:Farmingapp/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Farmingapp/loarding_page.dart';
import 'package:Farmingapp/welcome_page.dart';
import 'package:Farmingapp/login_page.dart';
import 'package:Farmingapp/signup_page.dart';
import 'package:Farmingapp/signup_successful_page.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:Farmingapp/product_details_page.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/editprofilepage.dart';
import 'package:Farmingapp/seller_dashboard.dart';
import 'package:Farmingapp/seller_profile_page.dart';
import 'package:Farmingapp/add_product_page.dart';
import 'package:Farmingapp/chat_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_service.dart';
import 'package:Farmingapp/auth/simple_signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔷 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure error reporting
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      print('🔐 Auth state changed: ${user != null ? "User logged in" : "User logged out"}');
    }, onError: (error) {
      print('❌ Auth state error: $error');
    });
    
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  // Handle Flutter errors
  FlutterError.onError = (details) {
    print('🚨 Flutter error: ${details.exception}');
    print('🚨 Stack trace: ${details.stack}');
  };
  
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
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SimpleSignupPage(),
        '/signup_successful': (context) => const SignUpSuccessfulPage(),
        '/farmer_dashboard': (context) => const FarmerDashboard(),
        '/cart': (context) => const CartPage(),
        '/product_details': (context) => const ProductDetailsPage(
          name: 'Seed Paddy',
          price: 'Rs. 500.00',
          image: 'assets/images/seed_paddy.png',
        ),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/seller_dashboard': (context) => const SellerDashboard(),
        '/seller_profile': (context) => const SellerProfilePage(),
        '/add_new_product': (context) => const AddProductPage(),
        '/simple_signup': (context) => const SimpleSignupPage(),
      },
    );
  }
}

// Add new SplashScreen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      print('🔍 Starting auth check...');
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('👤 No user logged in');
        Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }

      print('✅ Found logged in user: ${user.uid}');

      // Get user profile with retry logic
      DocumentSnapshot? userDoc;
      for (int i = 0; i < 3; i++) {
        try {
          userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          if (userDoc.exists) break;
          
          print('⚠️ Attempt ${i + 1}: User document not found');
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          print('❌ Error getting user data (attempt ${i + 1}): $e');
        }
      }

      if (!userDoc!.exists) {
        print('❌ No user profile found');
        await FirebaseAuth.instance.signOut();
        if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final userType = data['userType'] as String?;
      
      print('👤 User type found: $userType');

      if (mounted) {
        if (userType == 'Seller') {
          print('🚀 Navigating to seller dashboard');
          Navigator.pushReplacementNamed(context, '/seller_dashboard');
        } else {
          print('🚀 Navigating to farmer dashboard');
          Navigator.pushReplacementNamed(context, '/farmer_dashboard');
        }
      }
    } catch (e) {
      print('❌ Error in auth check: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingPage();
  }
}

// Simple authentication checking page
class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Use a Future instead of Stream for less chance of casting errors
      future: Future.delayed(
        const Duration(milliseconds: 500), 
        () => FirebaseAuth.instance.currentUser
      ),
      builder: (context, snapshot) {
        // Show loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }
        
        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // Get the user and check their type
          _checkUserType(context, snapshot.data!.uid);
          return const LoadingPage();
        }
        
        // No user is signed in
        return const WelcomePage();
      },
    );
  }
  
  // Function to check user type and navigate accordingly
  void _checkUserType(BuildContext context, String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
          if (doc.exists) {
            final data = doc.data();
            final userType = data?['userType'] as String? ?? 'Farmer';
            
            if (userType == 'Farmer') {
              Navigator.pushReplacementNamed(context, '/farmer_dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/seller_dashboard');
            }
          } else {
            // No user document, create a basic one
            _createBasicProfile(context, uid);
          }
        })
        .catchError((error) {
          print('Error checking user type: $error');
          // Default to farmer dashboard
          Navigator.pushReplacementNamed(context, '/farmer_dashboard');
        });
  }
  
  // Create a basic profile if one doesn't exist
  Future<void> _createBasicProfile(BuildContext context, String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': user.email ?? '',
        'username': user.email?.split('@')[0] ?? 'User',
        'phoneNumber': '',
        'userType': 'Farmer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      Navigator.pushReplacementNamed(context, '/farmer_dashboard');
    } catch (e) {
      print('Error creating basic profile: $e');
      Navigator.pushReplacementNamed(context, '/farmer_dashboard');
    }
  }
}
