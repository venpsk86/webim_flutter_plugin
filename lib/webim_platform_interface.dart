import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'webim_method_channel.dart';

abstract class WebimPlatform extends PlatformInterface {
  /// Constructs a WebimPlatform.
  WebimPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebimPlatform _instance = MethodChannelWebim();

  /// The default instance of [WebimPlatform] to use.
  ///
  /// Defaults to [MethodChannelWebim].
  static WebimPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebimPlatform] when
  /// they register themselves.
  static set instance(WebimPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> webimSession(
      {required String accountName, required String locationName, required String visitor}) {
    throw UnimplementedError('webimSession() has not been implemented.');
  }

  Future<String?> getSession() {
    throw UnimplementedError('getSession() has not been implemented.');
  }

  Future<String?> getMessagesHistory() {
    throw UnimplementedError('getSession() has not been implemented.');
  }
}
