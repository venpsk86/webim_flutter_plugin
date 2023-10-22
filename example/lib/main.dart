import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webim/webim.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _webimPlugin = Webim();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _webimPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            FilledButton(
              child: Text('webimSession'),
              onPressed: _webimSession,
            ),
            FilledButton(
              child: Text('getSession'),
              onPressed: _getSession,
            ),
            FilledButton(
              child: Text('getMessagesHistory'),
              onPressed: _getMessagesHistory,
            ),
          ],
        ),
      ),
    );
  }

  void _webimSession() async {
    final session = await _webimPlugin.webimSession(
      accountName: "demo.webim.ru",
      locationName: 'mobile',
      visitor: """{
        "id":"1",
        "display_name":"Никита",
        "hash":"ffadeb6aa3c788200824e311b9aa44cb"
      }"""
    );
    print('session: ${session!}');
  }

  void _getSession() async {
    final session = await _webimPlugin.getSession();
    print('session: ${session!}');
  }

  void _getMessagesHistory() async {
    final history = await _webimPlugin.getMessagesHistory();
    print('messagesHistory: ${history!}');
  }
}
