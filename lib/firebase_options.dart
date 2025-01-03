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
    apiKey: 'AIzaSyCbNmXaJKMhNPghJmI3rE7MxINxbFeOlq4',
    appId: '1:997570461834:web:e6eadd435829f0b0532d73',
    messagingSenderId: '997570461834',
    projectId: 'flavoreka',
    authDomain: 'flavoreka.firebaseapp.com',
    storageBucket: 'flavoreka.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKxsZMPLdO0bbPF7AfXTRVi9OyVQ800VY',
    appId: '1:997570461834:android:f146a386420c33c2532d73',
    messagingSenderId: '997570461834',
    projectId: 'flavoreka',
    storageBucket: 'flavoreka.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzhpt1rCi4V0GaoN6rnBiEpbMaSYQ08yQ',
    appId: '1:997570461834:ios:b831c55e4a033f7c532d73',
    messagingSenderId: '997570461834',
    projectId: 'flavoreka',
    storageBucket: 'flavoreka.firebasestorage.app',
    iosBundleId: 'com.jsphine.flavoreka',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDzhpt1rCi4V0GaoN6rnBiEpbMaSYQ08yQ',
    appId: '1:997570461834:ios:b831c55e4a033f7c532d73',
    messagingSenderId: '997570461834',
    projectId: 'flavoreka',
    storageBucket: 'flavoreka.firebasestorage.app',
    iosBundleId: 'com.jsphine.flavoreka',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCbNmXaJKMhNPghJmI3rE7MxINxbFeOlq4',
    appId: '1:997570461834:web:5a853470de456a3f532d73',
    messagingSenderId: '997570461834',
    projectId: 'flavoreka',
    authDomain: 'flavoreka.firebaseapp.com',
    storageBucket: 'flavoreka.firebasestorage.app',
  );
}
