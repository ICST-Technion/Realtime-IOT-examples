// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import 'firebase_options.dart';

String getStatusText(int status) {
  String statusText;
  switch (status) {
    case 1:
      statusText = 'IDLE';
      break;
    case 2:
      statusText = 'RUNNING';
      break;
    case 3:
      statusText = 'ERROR';
      break;
    default:
      statusText = 'UNKNOWN';
  }
  return statusText;
}

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
  int _command = 0;
  int _status = 0;
  String _statusButtonText = 'undefined';
  late DatabaseReference _commandRef;
  late DatabaseReference _statusRef;
  late StreamSubscription<DatabaseEvent> _commandSubscription;
  late StreamSubscription<DatabaseEvent> _statusSubscription;

  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    _statusRef = database.ref('status');
    _commandRef = database
        .ref()
        .child('command'); //here we are referencing children of the root node

    database.setLoggingEnabled(true); //output logs to console for debugging

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    if (!kIsWeb) {
      await _commandRef.keepSynced(true);
      await _statusRef.keepSynced(true);
    }

    setState(() {
      initialized = true;
    });

    try {
      await _commandRef.get(); // wait for initial read to complete
      await _statusRef.get();
      print(
        'Successful initial read from database',
      );
    } catch (err) {
      print(err);
    }

    _commandSubscription = _commandRef.onValue.listen(
      (DatabaseEvent event) {
        var data = event.snapshot.value as Map;
        _command = data['runningCount'] as int;
        // _commandType = data['type'] as int;

        setState(() {
          _error = null;
          _command = _command;
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },
    );

    _statusSubscription = _statusRef.onValue.listen(
      (DatabaseEvent event) {
        print('Status updated: ${event.snapshot.value}');
        _status = (event.snapshot.value ?? 0) as int;
        _statusButtonText = getStatusText(_status);
        setState(() {
          _statusButtonText = _statusButtonText;
          _error = null;
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        print('Error: ${error.code} ${error.message}');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _statusSubscription.cancel();
    _commandSubscription.cancel();
  }

  Future<void> _setcommand(int command_index) async {
    await _commandRef.update({'runningCount': ServerValue.increment(1)});
    await _commandRef.child('type').push().set(command_index);
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
                      'command count is $_command \n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Error:\n${_error!.message}',
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _setcommand(1);
                  },
                  child: const Text('1=Turn'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _setcommand(2);
                  },
                  child: const Text('2=Forward'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _setcommand(3);
                  },
                  child: const Text('3=Stop'),
                ),
              ),
            ],
          ),
          Flexible(
            child: Center(
                child: ElevatedButton(
              onPressed: () {}, // Empty callback
              style: ElevatedButton.styleFrom(
                backgroundColor: _status == 1 ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ), // Set the background color to red
              child: Text(
                  '\nCurrent status is ${_status == 0 ? 'undefined' : _statusButtonText}\n'),
            )),
          ),
        ],
      ),
    );
  } // build
} // _MyHomePageState
