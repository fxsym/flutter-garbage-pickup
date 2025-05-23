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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAKlr9yCa6Sq92q5924xqH8_RuqPyqCeWQ',
    appId: '1:383091515850:web:6acf66fd3132f5e9af2f33',
    messagingSenderId: '383091515850',
    projectId: 'wastechangeapk',
    authDomain: 'wastechangeapk.firebaseapp.com',
    storageBucket: 'wastechangeapk.firebasestorage.app',
    measurementId: 'G-79XZ3CZN3N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUTqW2woXacQPwaGHK3yR3kE70pCAFwdI',
    appId: '1:383091515850:android:bc21835aa0ecb241af2f33',
    messagingSenderId: '383091515850',
    projectId: 'wastechangeapk',
    storageBucket: 'wastechangeapk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIaojF-F0UBE_4tQFeefKn2WYBQyn92gk',
    appId: '1:383091515850:ios:de0275d5c62db4a0af2f33',
    messagingSenderId: '383091515850',
    projectId: 'wastechangeapk',
    storageBucket: 'wastechangeapk.firebasestorage.app',
    iosBundleId: 'com.example.wasteChangeApk',
  );
}
