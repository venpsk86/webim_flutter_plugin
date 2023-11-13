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

  Future<String?> getCurrentOperator() {
    return WebimPlatform.instance.getCurrentOperator();
  }

  Future<String?> getUnreadMessagesCount() {
    return WebimPlatform.instance.getUnreadMessagesCount();
  }

  Future<String?> sendMessage({required String message}) {
    return WebimPlatform.instance.sendMessage(message: message);
  }

  Future<String?> setVisitorTyping({required String? message}) {
    return WebimPlatform.instance.setVisitorTyping(message: message);
  }

  Future<String?> getLastMessages() {
    return WebimPlatform.instance.getLastMessages();
  }

  Future<String?> getNextMessages() {
    return WebimPlatform.instance.getNextMessages();
  }
}
