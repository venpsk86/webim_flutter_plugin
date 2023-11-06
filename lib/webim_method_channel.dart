import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'webim_platform_interface.dart';

/// An implementation of [WebimPlatform] that uses method channels.
class MethodChannelWebim extends WebimPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('webim');
  static const EventChannel _eventChannel = EventChannel('webim');

  // MethodChannelWebim() {
  //   _eventChannel.receiveBroadcastStream().listen((dynamic event) {
  //     print('Received event: $event');
  //   }, onError: (dynamic error) {
  //     print('Received error: ${error.message}');
  //   });
  // }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // static Stream<double> setWebimListener() async* {
  //   yield* _eventChannel.receiveBroadcastStream().asyncMap<double>((data) => data);
  // }

  @override
  Future<String> webimSession(
      {required String accountName, required String locationName, required String visitor}) async {
    final result = await methodChannel.invokeMethod<String>('webimSession',
        {'ACCOUNT_NAME': accountName, 'LOCATION_NAME': locationName, 'VISITOR': visitor});

    return result.toString();
  }

  @override
  Future<String> getSession() async {
    final result = await methodChannel.invokeMethod<String>('getSession');

    return result.toString();
  }

  @override
  Future<String> getUnreadMessagesCount() async {
    final result = await methodChannel.invokeMethod<String>('getUnreadMessagesCount');

    return result.toString();
  }

  @override
  Future<String> getCurrentOperator() async {
    final result = await methodChannel.invokeMethod<String>('getCurrentOperator');

    return result.toString();
  }

  @override
  Future<String> sendMessage({required String message}) async {
    final result = await methodChannel.invokeMethod<String>('sendMessage',
        {'MESSAGE': message});

    return result.toString();
  }

  @override
  Future<String> getLastMessages() async {
    final result = await methodChannel.invokeMethod<String>('getLastMessages');

    return result.toString();
  }
}
