import 'package:flutter_test/flutter_test.dart';
import 'package:webim/webim.dart';
import 'package:webim/webim_platform_interface.dart';
import 'package:webim/webim_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWebimPlatform
    with MockPlatformInterfaceMixin
    implements WebimPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WebimPlatform initialPlatform = WebimPlatform.instance;

  test('$MethodChannelWebim is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWebim>());
  });

  test('getPlatformVersion', () async {
    Webim webimPlugin = Webim();
    MockWebimPlatform fakePlatform = MockWebimPlatform();
    WebimPlatform.instance = fakePlatform;

    expect(await webimPlugin.getPlatformVersion(), '42');
  });
}
