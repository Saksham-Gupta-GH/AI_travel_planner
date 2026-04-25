import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase app.
///
/// Replace these values with your actual Firebase project configuration.
/// Run `flutterfire configure` to generate this file automatically.
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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB407UHpZzwV1R1ebTOJnxtfeD3yrc70VA',
    appId: '1:883191331221:web:90bda656a7961312ff9e9c',
    messagingSenderId: '883191331221',
    projectId: 'saksham230911186',
    authDomain: 'saksham230911186.firebaseapp.com',
    storageBucket: 'saksham230911186.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbz197hU71H5L9Mddtw-d3KTIQ6Sci7Xs',
    appId: '1:883191331221:android:b747fa4f5da7e7c5ff9e9c',
    messagingSenderId: '883191331221',
    projectId: 'saksham230911186',
    storageBucket: 'saksham230911186.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKDq5xPyB6Zue5wFljMPASL2QgEbj1FEY',
    appId: '1:883191331221:ios:6ae35ea60bb02e2cff9e9c',
    messagingSenderId: '883191331221',
    projectId: 'saksham230911186',
    storageBucket: 'saksham230911186.firebasestorage.app',
    iosBundleId: 'com.example.webApp2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKDq5xPyB6Zue5wFljMPASL2QgEbj1FEY',
    appId: '1:883191331221:ios:6ae35ea60bb02e2cff9e9c',
    messagingSenderId: '883191331221',
    projectId: 'saksham230911186',
    storageBucket: 'saksham230911186.firebasestorage.app',
    iosBundleId: 'com.example.webApp2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB407UHpZzwV1R1ebTOJnxtfeD3yrc70VA',
    appId: '1:883191331221:web:69f203d2f8f206feff9e9c',
    messagingSenderId: '883191331221',
    projectId: 'saksham230911186',
    authDomain: 'saksham230911186.firebaseapp.com',
    storageBucket: 'saksham230911186.firebasestorage.app',
  );
}
