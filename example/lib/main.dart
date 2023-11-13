import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json, utf8;
import 'package:crypto/crypto.dart';

import 'package:flutter/services.dart';
import 'package:webim/webim.dart';
import 'package:webim_example/models/message.dart';
import 'package:webim_example/models/operator.dart';

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
    _startListener();
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
              child: const Text('getUnreadMessagesCount'),
            ),
            FilledButton(
              onPressed: _getCurrentOperator,
              child: const Text('getCurrentOperator'),
            ),
            FilledButton(
              onPressed: _getLastMessages,
              child: const Text('getLastMessages'),
            ),
            FilledButton(
              onPressed: _getNextMessages,
              child: const Text('getNextMessages'),
            ),
            FilledButton(
              onPressed: _setVisitorTyping,
              child: const Text('setVisitorTyping'),
            ),
            FilledButton(
              onPressed: _setVisitorTypingNull,
              child: const Text('setVisitorTypingNull'),
            ),
          ],
        ),
      ),
    );
  }



  void _webimSession() async {
    final key = utf8.encode('84a68f78a5932fca137d57155e2a5f9c');
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
      accountName: "tempojoborg",
      locationName: 'default',
      visitor: json.encode(visitor)
    );
  }

  void _getSession() async {
    final session = await _webimPlugin.getSession();
    print('session: ${session!}');
  }

  void _sendMessage() async {
    final count = await _webimPlugin.sendMessage(message: '123');
    print('messageId: ${count!}');
  }

  void _getUnreadMessagesCount() async {
    final count = await _webimPlugin.getUnreadMessagesCount();
    print('unreadMessagesCount: ${count!}');
  }

  void _getCurrentOperator() async {
    String? str = await _webimPlugin.getCurrentOperator();
    final Operator operator = operatorModelFromJson(str ?? '');
  }

  void _getLastMessages() async {
    String? str = await _webimPlugin.getLastMessages();
    final List<Message> messages = modelMessageFromJson(str ?? '');

    print('getLastMessages: ${messages![messages.length - 1].text}');
    print('getLastMessagesLength: ${messages.length}');
  }

  void _getNextMessages() async {
    String? str = await _webimPlugin.getNextMessages();
    final List<Message> messages = modelMessageFromJson(str ?? '');

    print('getNextMessages: ${messages![messages.length - 1].text!}');
    print('getNextMessagesLength: ${messages.length}');
  }

  void _setVisitorTyping() async {
    await _webimPlugin.setVisitorTyping(message: 'typing');
  }

  void _setVisitorTypingNull() async {
    await _webimPlugin.setVisitorTyping(message: null);
  }
}
