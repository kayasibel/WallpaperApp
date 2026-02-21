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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTF9YC4p2wbnzWlaMJ6Qg73IEdyxNmAJk',
    appId: '1:47010221246:android:bc1e8b6320c2de54f9a2ef',
    messagingSenderId: '47010221246',
    projectId: 'anime-wallpaper-1fd27',
    storageBucket: 'anime-wallpaper-1fd27.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8Sjvq6NRnKyqWp-BcnMCF8l0EoCdqQjI',
    appId: '1:932174522384:ios:cca6741a8c67f852eac295',
    messagingSenderId: '932174522384',
    projectId: 'wallpaper-app-3c8c6',
    storageBucket: 'wallpaper-app-3c8c6.firebasestorage.app',
    iosClientId: '932174522384-bcfi1e5epb1tmp7oijqsdfbpf8meip6k.apps.googleusercontent.com',
    iosBundleId: 'com.example.wallpaperThemeApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDakVvwuWAkA2YsZMYEldoDPfbKvWE49w',
    appId: '1:932174522384:web:54d834f9826f31a9eac295',
    messagingSenderId: '932174522384',
    projectId: 'wallpaper-app-3c8c6',
    authDomain: 'wallpaper-app-3c8c6.firebaseapp.com',
    storageBucket: 'wallpaper-app-3c8c6.firebasestorage.app',
    measurementId: 'G-7XJRBJX5X6',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8Sjvq6NRnKyqWp-BcnMCF8l0EoCdqQjI',
    appId: '1:932174522384:ios:cca6741a8c67f852eac295',
    messagingSenderId: '932174522384',
    projectId: 'wallpaper-app-3c8c6',
    storageBucket: 'wallpaper-app-3c8c6.firebasestorage.app',
    iosClientId: '932174522384-bcfi1e5epb1tmp7oijqsdfbpf8meip6k.apps.googleusercontent.com',
    iosBundleId: 'com.example.wallpaperThemeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCDakVvwuWAkA2YsZMYEldoDPfbKvWE49w',
    appId: '1:932174522384:web:f0bed54fbf18f244eac295',
    messagingSenderId: '932174522384',
    projectId: 'wallpaper-app-3c8c6',
    authDomain: 'wallpaper-app-3c8c6.firebaseapp.com',
    storageBucket: 'wallpaper-app-3c8c6.firebasestorage.app',
    measurementId: 'G-T2W48LY9PR',
  );

}