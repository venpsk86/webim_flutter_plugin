import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'webim_platform_interface.dart';

/// An implementation of [WebimPlatform] that uses method channels.
class MethodChannelWebim extends WebimPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('webim');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

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
  Future<String> getMessagesHistory() async {
    final result = await methodChannel.invokeMethod<String>('getMessagesHistory');

    return result.toString();
  }
}
