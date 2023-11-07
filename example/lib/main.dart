import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json, utf8;
import 'package:crypto/crypto.dart';

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
  static const stream = EventChannel('events');

  late StreamSubscription _streamSubscription;

  void _startListener() {
    _streamSubscription = stream.receiveBroadcastStream().listen(_listenStream);
  }

  void _cancelListener() {
    _streamSubscription.cancel();
  }

  void _listenStream(value) {
    debugPrint("Received From Native:  $value\n");
  }

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
              onPressed: _webimSession,
              child: const Text('webimSession'),
            ),
            FilledButton(
              onPressed: _getSession,
              child: const Text('getSession'),
            ),
            FilledButton(
              onPressed: _sendMessage,
              child: const Text('sendMessage'),
            ),
            FilledButton(
              onPressed: _getUnreadMessagesCount,
              child: const Text('getMessagesHistory'),
            ),
            FilledButton(
              onPressed: _getCurrentOperator,
              child: const Text('getCurrentOperator'),
            ),
            FilledButton(
              onPressed: _getLastMessages,
              child: const Text('_getLastMessages'),
            ),
          ],
        ),
      ),
    );
  }



  void _webimSession() async {
    final key = utf8.encode('eaf24dc27abe7b1f350849c7fc375450');
    Map map = {'id': '6762', 'display_name': 'Евгений', 'phone': '79229734344'};
    var sortedByKeyMap = Map.fromEntries(map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
    List list = [];
    Map visitor = {};
    sortedByKeyMap.forEach((k, v) => list.add(v));
    final bytes = utf8.encode(list.join());

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes).toString();
    visitor['fields'] = map;
    visitor['hash'] = digest;

    final session = await _webimPlugin.webimSession(
      accountName: "developprotempojoborg001",
      locationName: 'default',
      visitor: json.encode(visitor)
    );

    _startListener();
  }

  void _getSession() async {
    final session = await _webimPlugin.getSession();
    print('session: ${session!}');
  }

  void _sendMessage() async {
    final count = await _webimPlugin.sendMessage(message: 'Message from flutter plugin');
    print('messageId: ${count!}');
  }

  void _getUnreadMessagesCount() async {
    final count = await _webimPlugin.getUnreadMessagesCount();
    print('messagesCount: ${count!}');
  }

  void _getCurrentOperator() async {
    final count = await _webimPlugin.getCurrentOperator();
    print('operator: ${count!}');
  }

  void _getLastMessages() async {
    final messages = await _webimPlugin.getLastMessages();
  }
}
