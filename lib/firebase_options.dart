import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart' show TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;           // Sẽ thêm sau nếu cần
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCv-3XWQUOP5IwrPf0h1from627ui8jtFA",
    authDomain: "quanlycongviechoahong.firebaseapp.com",
    projectId: "quanlycongviechoahong",
    storageBucket: "quanlycongviechoahong.firebasestorage.app",
    messagingSenderId: "312815493454",
    appId: "1:312815493454:web:b6674d31bd8c4756d13e1f",
    measurementId: "G-KSEGLFTC9T",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCv-3XWQUOP5IwrPf0h1from627ui8jtFA",
    appId: "1:312815493454:android:b6674d31bd8c4756d13e1f",
    messagingSenderId: "312815493454",
    projectId: "quanlycongviechoahong",
    storageBucket: "quanlycongviechoahong.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCv-3XWQUOP5IwrPf0h1from627ui8jtFA",
    appId: "1:312815493454:ios:b6674d31bd8c4756d13e1f", // Thay sau khi config iOS
    messagingSenderId: "312815493454",
    projectId: "quanlycongviechoahong",
    storageBucket: "quanlycongviechoahong.firebasestorage.app",
    iosBundleId: 'com.premiumisme.quanlycongviechoahong', // Thay theo bundle ID của bạn
  );
}