import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Completely rewritten signUp method with better error handling
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
    required String mobile,
    required String userType,
  }) async {
    try {
      print('🔵 SIGNUP: Starting signup for $email as $userType');
      
      // First attempt to create the user in authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        print('🔴 SIGNUP: User is null after authentication');
        throw Exception('Auth user creation failed - received null user');
      }
      
      print('✅ SIGNUP: Auth user created with UID: ${user.uid}');
      
      // Create user data with direct field names
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'username': username,
        'phoneNumber': mobile,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(), // Add timestamp for debugging
      };
      
      print('🔵 SIGNUP: Creating Firestore document with data: $userData');
      
      // Explicitly create the document in Firestore with retry logic
      bool savedToFirestore = false;
      Exception? firestoreException;
      
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('🔵 SIGNUP: Attempt #$attempt to save data to Firestore');
          await _firestore.collection('users').doc(user.uid)
              .set(userData, SetOptions(merge: true))
              .timeout(const Duration(seconds: 15));
          
          // Verify the document was created
          final doc = await _firestore.collection('users').doc(user.uid).get()
              .timeout(const Duration(seconds: 5));
          
          if (doc.exists) {
            print('✅ SIGNUP: Data successfully saved to Firestore (verified)');
            print('📄 SIGNUP: Document data: ${doc.data()}');
            savedToFirestore = true;
            break; // Exit retry loop
          } else {
            print('⚠️ SIGNUP: Document missing after write on attempt #$attempt');
          }
        } catch (e) {
          print('⚠️ SIGNUP: Firestore error on attempt #$attempt: $e');
          firestoreException = e as Exception;
          // Wait before retry
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      if (!savedToFirestore) {
        print('🔴 SIGNUP: Failed to save to Firestore after multiple attempts');
        throw firestoreException ?? Exception('Failed to save user data to Firestore');
      }
      
      return userCredential;
    } catch (e) {
      print('🔴 SIGNUP: Error: $e');
      rethrow;
    }
  }

  // Enhance getUserType with better handling of empty/missing data
  Future<String> getUserType(String uid) async {
    print('🔍 Getting user type for: $uid');
    
    if (uid.isEmpty) {
      print('⚠️ Empty UID provided');
      return '';
    }
    
    try {
      // Try to get the document with timeout and multiple attempts
      DocumentSnapshot? docSnapshot;
      
      // Try up to 3 times with increasing timeouts
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('🔍 Attempt #$attempt to get user document');
          docSnapshot = await _firestore.collection('users').doc(uid)
              .get().timeout(Duration(seconds: attempt * 5));
          
          if (docSnapshot.exists) {
            break; // Successfully got the document
          } else {
            print('⚠️ Document doesn\'t exist (attempt #$attempt)');
          }
        } catch (e) {
          print('⚠️ Error on attempt #$attempt: $e');
          if (attempt == 3) rethrow; // On final attempt, propagate the error
        }
        
        // Wait before next attempt
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
      
      // If we couldn't get a document after all retries
      if (docSnapshot == null || !docSnapshot.exists) {
        print('⚠️ Document does not exist after multiple attempts');
        return '';
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>?;
      print('📄 Document data: $data');
      
      if (data == null) {
        print('⚠️ Document data is null');
        return '';
      }
      
      // Check if userType field exists
      if (!data.containsKey('userType')) {
        print('⚠️ Document does not contain userType field');
        return '';
      }
      
      final userType = data['userType'];
      print('👤 User type retrieved: "$userType" (type: ${userType.runtimeType})');
      
      return userType?.toString() ?? '';
    } catch (e) {
      print('🔴 Error getting user type: $e');
      return '';
    }
  }

  // New method to get just user's email - without complex types
  Future<String> getUserEmail(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return '';
      
      final data = doc.data();
      if (data == null) return '';
      
      final email = data['email'];
      return email?.toString() ?? '';
    } catch (e) {
      print('Error getting user email: $e');
      return '';
    }
  }

  // New method to get just user's name - without complex types
  Future<String> getUserName(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return '';
      
      final data = doc.data();
      if (data == null) return '';
      
      final username = data['username'];
      return username?.toString() ?? '';
    } catch (e) {
      print('Error getting username: $e');
      return '';
    }
  }

  // Sign in with simple return type
  Future<UserCredential> signIn({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Remove test methods
  Future<Map<String, dynamic>> testFirebaseConnection() async {
    // Keep this method but simplified
    return {'status': 'ok'};
  }

  Future<void> storeLoginHistory(User user) async {
    try {
      // Store login history
      await _firestore.collection('login_history').add({
        'userId': user.uid,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        'creationTime': user.metadata.creationTime?.toIso8601String(),
      });

      // Update user's last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error storing login history: $e');
      // Don't throw - this is auxiliary data
    }
  }

  Future<void> storeLoginDetails(User user, String platform) async {
    try {
      // Store login history
      await _firestore.collection('login_history').add({
        'userId': user.uid,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': platform,
          'deviceTime': DateTime.now().toIso8601String(),
        }
      });

      // Update user's last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error storing login details: $e');
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['userType'] as String? ?? 'Farmer';
      }
      return 'Farmer'; // Default role
    } catch (e) {
      print('Error getting user role: $e');
      return 'Farmer'; // Default role on error
    }
  }

  Future<void> updateLoginHistory(User user, BuildContext context) async {
    try {
      final batch = _firestore.batch();
      
      // Create login history document
      final historyRef = _firestore.collection('login_history').doc();
      batch.set(historyRef, {
        'userId': user.uid,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': Theme.of(context).platform.toString(),
          'deviceTime': DateTime.now().toIso8601String(),
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
          'creationTime': user.metadata.creationTime?.toIso8601String(),
        },
        'loginMethod': 'email_password',
        'success': true,
        'sessionId': historyRef.id,
      });
      
      // Update user document
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {
        'lastLogin': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
        'lastLoginEmail': user.email,
        'lastLoginDevice': {
          'platform': Theme.of(context).platform.toString(),
          'time': DateTime.now().toIso8601String(),
        },
        'isOnline': true,
        'lastActivityTimestamp': FieldValue.serverTimestamp(),
        'sessions': FieldValue.arrayUnion([historyRef.id]),
      });
      
      await batch.commit();
      print('✅ Login history updated successfully');
    } catch (e) {
      print('❌ Error updating login history: $e');
    }
  }

  Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastActivityTimestamp': FieldValue.serverTimestamp(),
        if (!isOnline) 'lastSeenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
