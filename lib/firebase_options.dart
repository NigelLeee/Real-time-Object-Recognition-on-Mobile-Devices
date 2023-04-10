// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBlDUeiV_kTq45Yt0lPcl_Ttrblr393CpA',
    appId: '1:965832673404:web:5447a7fce56a0a6ecc21f9',
    messagingSenderId: '965832673404',
    projectId: 'fyprealtimeobjectrecognition',
    authDomain: 'fyprealtimeobjectrecognition.firebaseapp.com',
    storageBucket: 'fyprealtimeobjectrecognition.appspot.com',
    measurementId: 'G-188R3SRY9D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcawfJHEl9kijCfgftV_CmNFsoVrh6TKI',
    appId: '1:965832673404:android:674f3aa104d74484cc21f9',
    messagingSenderId: '965832673404',
    projectId: 'fyprealtimeobjectrecognition',
    storageBucket: 'fyprealtimeobjectrecognition.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1oT70xSPbpuLyf5h6A0YfNR6GKDBowpo',
    appId: '1:965832673404:ios:66f76baf863415e9cc21f9',
    messagingSenderId: '965832673404',
    projectId: 'fyprealtimeobjectrecognition',
    storageBucket: 'fyprealtimeobjectrecognition.appspot.com',
    iosClientId: '965832673404-thub62u66llghisivdu6l91k31agfu43.apps.googleusercontent.com',
    iosBundleId: 'com.example.realTimeObjectRecognitionApplication',
  );
}