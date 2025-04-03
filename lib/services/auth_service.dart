import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a single instance
  static final AuthService instance = AuthService._();
  
  // Private constructor
  AuthService._();

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['userType'] ?? 'Farmer';
    } catch (e) {
      print('Error getting user role: $e');
      return 'Farmer';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>> handleLogin(String email, String password) async {
    try {
      print('🔄 Starting login process for: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return {'success': false, 'error': 'Login failed'};
      }

      final uid = credential.user!.uid;
      print('✅ Auth successful for UID: $uid');

      // Create or update user document
      try {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          print('⚠️ Creating new user profile');
          // Create new user profile
          await userRef.set({
            'uid': uid,
            'email': email,
            'userType': 'Farmer', // Default role
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isOnline': true,
          });
          return {
            'success': true,
            'userType': 'Farmer',
            'uid': uid,
            'isNewUser': true
          };
        }

        // Update existing user
        print('✅ Updating existing user profile');
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'isOnline': true,
        });

        final userData = userDoc.data()!;
        final userType = userData['userType'] as String? ?? 'Farmer';
        
        print('👤 User type: $userType');
        return {
          'success': true,
          'userType': userType,
          'uid': uid,
          'isNewUser': false
        };
      } catch (e) {
        print('❌ Firestore error: $e');
        return {'success': false, 'error': 'Database error: $e'};
      }
    } catch (e) {
      print('❌ Auth error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Add method to check current login state
  Future<Map<String, dynamic>> checkLoginState() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'isLoggedIn': false};
      }

      print('🔍 Checking login state for user: ${user.uid}');
      
      // Try to get user profile
      DocumentSnapshot? userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // If profile doesn't exist, create one
      if (!userDoc.exists) {
        print('⚠️ Profile not found, creating default profile');
        final defaultProfile = {
          'uid': user.uid,
          'email': user.email,
          'userType': 'Farmer', // Default role
          'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(defaultProfile);
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final userType = data['userType'] as String? ?? 'Farmer';
      
      return {
        'isLoggedIn': true,
        'userType': userType,
        'uid': user.uid
      };
    } catch (e) {
      print('❌ Error in checkLoginState: $e');
      return {'isLoggedIn': false, 'error': e.toString()};
    }
  }
}
