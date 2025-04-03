import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Update user message notification count
  static Future<void> updateMessageCount(String userId, {int? setValue}) async {
    try {
      if (userId.isEmpty) return;
      
      final userDoc = _firestore.collection('users').doc(userId);
      
      if (setValue != null) {
        // Set to a specific value
        await userDoc.update({'unreadMessages': setValue});
      } else {
        // Increment the current value
        await userDoc.update({'unreadMessages': FieldValue.increment(1)});
      }
    } catch (e) {
      print('Error updating message notification count: $e');
    }
  }

  // Reset message notification count
  static Future<void> resetMessageCount(String userId) async {
    try {
      if (userId.isEmpty) return;
      await _firestore.collection('users').doc(userId).update({
        'unreadMessages': 0
      });
    } catch (e) {
      print('Error resetting message notification count: $e');
    }
  }

  // Create a product notification for farmers
  static Future<void> createProductNotification(String productId, String productName, String sellerId) async {
    try {
      // Create a notification record in the "notifications" collection
      await _firestore.collection('notifications').add({
        'type': 'new_product',
        'productId': productId,
        'productName': productName,
        'sellerId': sellerId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      // Update the new product notification counter for all farmers
      final farmersSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Farmer')
          .get();
          
      final batch = _firestore.batch();
      
      for (var doc in farmersSnapshot.docs) {
        batch.update(doc.reference, {
          'newProductNotifications': FieldValue.increment(1)
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error creating product notification: $e');
    }
  }
  
  // Get user notification counts
  static Stream<DocumentSnapshot> getUserNotifications(String userId) {
    if (userId.isEmpty) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  // Mark product notifications as read for a user
  static Future<void> markProductNotificationsAsRead(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'newProductNotifications': 0
      });
    } catch (e) {
      print('Error marking product notifications as read: $e');
    }
  }
}
