import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper class to manage Firestore index-related issues
class FirebaseIndexHelper {
  /// Shows a dialog explaining the Firestore index requirement
  static void showIndexRequiredDialog(BuildContext context, String error) {
    // Extract the index URL if present in the error
    String? indexUrl = _extractIndexUrlFromError(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Index Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_list, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'This query requires a Firestore index to work properly.',
              textAlign: TextAlign.center,
            ),
            if (indexUrl != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Click the button below to create the required index.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (indexUrl != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Create Index'),
              onPressed: () {
                Navigator.pop(context);
                _launchUrl(indexUrl);
              },
            ),
        ],
      ),
    );
  }
  
  /// Extracts Firebase console URL for index creation from error message
  static String? _extractIndexUrlFromError(String error) {
    // Firebase errors typically contain a URL like:
    // https://console.firebase.google.com/project/YOUR_PROJECT/database/firestore/indexes?create_composite=...
    final RegExp urlRegExp = RegExp(
      r'https://console\.firebase\.google\.com/[^\s"]+',
      caseSensitive: false,
    );
    
    final match = urlRegExp.firstMatch(error);
    return match?.group(0);
  }
  
  /// Launch URL helper
  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  
  /// Checks if an error is an index-related error
  static bool isIndexError(dynamic error) {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('index') && 
           (errorString.contains('required') || errorString.contains('missing') || errorString.contains('failed-precondition'));
  }
}
