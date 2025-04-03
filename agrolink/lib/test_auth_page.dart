import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestAuthPage extends StatefulWidget {
  const TestAuthPage({Key? key}) : super(key: key);

  @override
  _TestAuthPageState createState() => _TestAuthPageState();
}

class _TestAuthPageState extends State<TestAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _result = 'No test run yet';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing signup...';
    });

    try {
      // Generate a unique test email
      final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
      _emailController.text = testEmail;
      
      // Step 1: Create Firebase Auth user
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: testEmail,
        password: _passwordController.text,
      );
      
      if (credential.user == null) {
        throw Exception("Auth successful but user is null");
      }
      
      final uid = credential.user!.uid;
      _appendResult('✅ Auth user created: $uid');
      
      // Step 2: Create Firestore document
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': testEmail,
          'username': 'Test User',
          'userType': 'Farmer',
          'testData': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _appendResult('✅ Firestore document created');
        
        // Verify document exists
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
            
        if (doc.exists) {
          _appendResult('✅ Firestore document verified');
        } else {
          _appendResult('❌ Firestore document not found after creation');
        }
      } catch (firestoreError) {
        _appendResult('❌ Firestore error: $firestoreError');
      }
      
      // Clean up the test user
      try {
        await credential.user!.delete();
        _appendResult('✅ Test user deleted');
      } catch (e) {
        _appendResult('⚠️ Could not delete test user: $e');
      }
      
    } catch (e) {
      _appendResult('❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _appendResult(String message) {
    setState(() {
      _result = _result + '\n' + message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Test password (min 6 chars)',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testSignUp,
              child: Text('Test Auth & Firestore'),
            ),
            SizedBox(height: 24),
            Text('Results:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.1),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
