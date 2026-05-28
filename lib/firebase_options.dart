import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDr505NyWCdSG3Y1NPLa9Fx8N0lSeOyhcc',
    appId: '1:802913604472:web:3193041600f5006c7a6e8d',
    messagingSenderId: '802913604472',
    projectId: 'mindspace-b0c2b',
    authDomain: 'mindspace-b0c2b.firebaseapp.com',
    storageBucket: 'mmindspace-b0c2b.firebasestorage.app',
  );
}