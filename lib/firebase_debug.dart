import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDebugger {
  static Future<Map<String, dynamic>> diagnoseFirebaseIssues() async {
    final result = <String, dynamic>{};
    
    // Check Firebase Auth
    try {
      result['auth_initialized'] = FirebaseAuth.instance != null;
      result['current_user'] = FirebaseAuth.instance.currentUser?.uid;
      result['user_email'] = FirebaseAuth.instance.currentUser?.email;
    } catch (e) {
      result['auth_error'] = e.toString();
    }
    
    // Check Firestore
    try {
      // Test if Firestore is available
      result['firestore_initialized'] = FirebaseFirestore.instance != null;
      
      // Try a simple read operation
      try {
        final testRead = await FirebaseFirestore.instance
            .collection('test_read')
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 5));
        result['firestore_read_test'] = 'Success';
        result['docs_count'] = testRead.docs.length;
      } catch (e) {
        result['firestore_read_error'] = e.toString();
      }
      
      // Check if user is logged in and try accessing their profile
      if (FirebaseAuth.instance.currentUser != null) {
        try {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get()
              .timeout(const Duration(seconds: 5));
          
          result['user_doc_exists'] = userDoc.exists;
          if (userDoc.exists) {
            result['user_data'] = userDoc.data();
          }
        } catch (e) {
          result['user_doc_error'] = e.toString();
        }
      }
    } catch (e) {
      result['firestore_error'] = e.toString();
    }
    
    print('🔍 Firebase Debug Results: $result');
    return result;
  }
}
