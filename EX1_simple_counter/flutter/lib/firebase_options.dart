// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

// ********************
// to watch the database live, go to - https://console.firebase.google.com/project/esp32-firebase-ea2d2/database/esp32-firebase-ea2d2-default-rtdb/data/~2F
// use gmail login - icsttechnion@gmailcom  (password provided by course staff)
// ********************

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDlvKIG2e7CWdQq6h7vVEhywx5jGzvRgaw',
    appId: '1:751518757733:web:c3ec762fbfbb2202b1a78c',
    messagingSenderId: '751518757733',
    projectId: 'esp32-firebase-ea2d2',
    authDomain: 'esp32-firebase-ea2d2.firebaseapp.com',
    databaseURL:
        'https://esp32-firebase-ea2d2-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
    measurementId: 'G-JN95N1JV2E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlvKIG2e7CWdQq6h7vVEhywx5jGzvRgaw',
    appId: '1:751518757733:android:7f288c63c338b256b1a78c',
    messagingSenderId: '751518757733',
    projectId: 'esp32-firebase-ea2d2',
    databaseURL:
        'https://esp32-firebase-ea2d2-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'esp32-firebase-ea2d2.appspot.com',
  );

  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'AIzaSyDooSUGSf63Ghq02_iIhtnmwMDs4HlWS6c',
  //   appId: '1:406099696497:ios:e31ee2c5dc99d4743574d0',
  //   messagingSenderId: '406099696497',
  //   projectId: 'flutterfire-e2e-tests',
  //   databaseURL:
  //       'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  //   storageBucket: 'flutterfire-e2e-tests.appspot.com',
  //   androidClientId:
  //       '406099696497-17qn06u8a0dc717u8ul7s49ampk13lul.apps.googleusercontent.com',
  //   iosClientId:
  //       '406099696497-1ugbsqv8nkfn788ep0k233e750aupb7u.apps.googleusercontent.com',
  //   iosBundleId: 'io.flutter.plugins.firebaseDatabaseExample',
  // );

  // static const FirebaseOptions macos = FirebaseOptions(
  //   apiKey: 'AIzaSyDooSUGSf63Ghq02_iIhtnmwMDs4HlWS6c',
  //   appId: '1:406099696497:ios:e31ee2c5dc99d4743574d0',
  //   messagingSenderId: '406099696497',
  //   projectId: 'flutterfire-e2e-tests',
  //   databaseURL:
  //       'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  //   storageBucket: 'flutterfire-e2e-tests.appspot.com',
  //   androidClientId:
  //       '406099696497-17qn06u8a0dc717u8ul7s49ampk13lul.apps.googleusercontent.com',
  //   iosClientId:
  //       '406099696497-1ugbsqv8nkfn788ep0k233e750aupb7u.apps.googleusercontent.com',
  //   iosBundleId: 'io.flutter.plugins.firebaseDatabaseExample',
  // );
}
