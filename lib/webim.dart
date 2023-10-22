import 'webim_platform_interface.dart';

class Webim {
  Future<String?> getPlatformVersion() {
    return WebimPlatform.instance.getPlatformVersion();
  }

  Future<String?> webimSession(
      {required String accountName, required String locationName, required String visitor}) {
    return WebimPlatform.instance
        .webimSession(accountName: accountName, locationName: locationName, visitor: visitor);
  }

  Future<String?> getSession() {
    return WebimPlatform.instance.getSession();
  }

  Future<String?> getMessagesHistory() {
    return WebimPlatform.instance.getMessagesHistory();
  }
}
