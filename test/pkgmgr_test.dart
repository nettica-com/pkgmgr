import 'package:flutter_test/flutter_test.dart';
import 'package:pkgmgr/pkgmgr.dart';
import 'package:pkgmgr/pkgmgr_platform_interface.dart';
import 'package:pkgmgr/pkgmgr_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPkgmgrPlatform
    with MockPlatformInterfaceMixin
    implements PkgmgrPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<Object?>> getInstalledApps({bool showSystem = false}) {
    // TODO: implement getInstalledApps
    throw UnimplementedError();
  }
}

void main() {
  final PkgmgrPlatform initialPlatform = PkgmgrPlatform.instance;

  test('$MethodChannelPkgmgr is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPkgmgr>());
  });

  test('getPlatformVersion', () async {
    Pkgmgr pkgmgrPlugin = Pkgmgr();
    MockPkgmgrPlatform fakePlatform = MockPkgmgrPlatform();
    PkgmgrPlatform.instance = fakePlatform;

    expect(await pkgmgrPlugin.getPlatformVersion(), '42');
  });
}
