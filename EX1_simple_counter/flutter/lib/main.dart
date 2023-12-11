// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ********************
// to watch the database live, go to - https://console.firebase.google.com/project/esp32-firebase-ea2d2/database/esp32-firebase-ea2d2-default-rtdb/data/~2F
// use gmail login - icsttechnion@gmailcom  (password provided by course staff)
// ********************

//Project Console: https://console.firebase.google.com/project/esp32-firebase-ea2d2/overview
// Hosting URL: https://esp32-firebase-ea2d2.web.app

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MaterialApp(
      title: 'Flutter Firebase RTDB Example',
      home: MyHomePage(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late DatabaseReference _counterRef;
  late StreamSubscription<DatabaseEvent> _counterSubscription;
  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    _counterRef = FirebaseDatabase.instance.ref('counter');

    final database = FirebaseDatabase.instance;

    database.setLoggingEnabled(true);

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    if (!kIsWeb) {
      await _counterRef.keepSynced(true);
    }

    setState(() {
      initialized = true;
    });

    try {
      final counterSnapshot = await _counterRef.get();
      print(
        'Connected to directly configured database and read '
        '${counterSnapshot.value}',
      );
    } catch (err) {
      print(err);
    }

    _counterSubscription = _counterRef.onValue.listen(
      (DatabaseEvent event) {
        setState(() {
          _error = null;
          _counter = (event.snapshot.value ?? 0) as int;
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    _counterSubscription.cancel();
  }

  Future<void> _increment() async {
    await _counterRef.set(ServerValue.increment(1));
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Database Example'),
      ),
      body: Column(
        children: [
          Flexible(
            child: Center(
              child: _error == null
                  ? Text(
                      'Button tapped $_counter time${_counter == 1 ? '' : 's'}.\n\n'
                      'This value is synced with Firebase RTDB.',
                    )
                  : Text(
                      'Error retrieving button tap count:\n${_error!.message}',
                    ),
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: _increment,
              child: const Text('Increment'),
            ),
          ),
        ],
      ),
    );
  }
}
