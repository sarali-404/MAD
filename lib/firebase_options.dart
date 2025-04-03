import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Add debugging for options being used
    final options = const FirebaseOptions(
      apiKey: 'AIzaSyBrDT4BlYKd8i_Z-RpLZMlts6gw0dxs7B0',
      appId: '1:212474718113:android:77f696627baa40698fcde0',
      messagingSenderId: '212474718113',
      projectId: 'agrolink-996ca',
      storageBucket: 'agrolink-996ca.firebasestorage.app',
    );
    
    print('Using Firebase Options:');
    print('- apiKey: ${options.apiKey}');
    print('- projectId: ${options.projectId}');
    print('- appId: ${options.appId}');
    
    return options;
  }
}
