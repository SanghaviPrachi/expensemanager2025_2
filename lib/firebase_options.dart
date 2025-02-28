// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0IFphAjWch1kCjr-Jxj-j8-5Wegng3-0',
    appId: '1:343301594938:web:52fb63d26253dc6254fa03',
    messagingSenderId: '343301594938',
    projectId: 'expense-manager-2025-2206f',
    authDomain: 'expense-manager-2025-2206f.firebaseapp.com',
    storageBucket: 'expense-manager-2025-2206f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBprZhXTgHgC-HIaldEjRRgnp57N5MWZH4',
    appId: '1:343301594938:android:7478cf1d414b9a2254fa03',
    messagingSenderId: '343301594938',
    projectId: 'expense-manager-2025-2206f',
    storageBucket: 'expense-manager-2025-2206f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHqOsahZD_jAkWrfXJAjbGUaZsL2VvwHA',
    appId: '1:343301594938:ios:e57f0d95e81bdc6154fa03',
    messagingSenderId: '343301594938',
    projectId: 'expense-manager-2025-2206f',
    storageBucket: 'expense-manager-2025-2206f.firebasestorage.app',
    iosBundleId: 'com.example.expensemanager2025',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDHqOsahZD_jAkWrfXJAjbGUaZsL2VvwHA',
    appId: '1:343301594938:ios:e57f0d95e81bdc6154fa03',
    messagingSenderId: '343301594938',
    projectId: 'expense-manager-2025-2206f',
    storageBucket: 'expense-manager-2025-2206f.firebasestorage.app',
    iosBundleId: 'com.example.expensemanager2025',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC0IFphAjWch1kCjr-Jxj-j8-5Wegng3-0',
    appId: '1:343301594938:web:999cd7160ea1d5e054fa03',
    messagingSenderId: '343301594938',
    projectId: 'expense-manager-2025-2206f',
    authDomain: 'expense-manager-2025-2206f.firebaseapp.com',
    storageBucket: 'expense-manager-2025-2206f.firebasestorage.app',
  );
}
