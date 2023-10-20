
import 'webim_platform_interface.dart';

class Webim {
  Future<String?> getPlatformVersion() {
    return WebimPlatform.instance.getPlatformVersion();
  }
}
