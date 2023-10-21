import 'webim_platform_interface.dart';

class Webim {
  Future<String?> getPlatformVersion() {
    return WebimPlatform.instance.getPlatformVersion();
  }

  Future<String?> webimSession(
      {required String accountName, required String locationName}) {
    return WebimPlatform.instance
        .webimSession(accountName: accountName, locationName: locationName);
  }
}
