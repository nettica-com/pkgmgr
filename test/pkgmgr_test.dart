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
  Future<List<Object?>> getInstalledApps({bool showSystem = false}) =>
      Future.value([
        {'name': 'Test App', 'package': 'com.example.test', 'icon': 'aGVsbG8='},
      ]);

  @override
  Future<List<Object?>> getInstalledAppsInfo({bool showSystem = false}) =>
      Future.value([
        {'name': 'Test App', 'package': 'com.example.test', 'icon': null},
      ]);

  @override
  Future<String?> getAppIcon(String packageId) =>
      Future.value(packageId == 'com.example.test' ? 'aGVsbG8=' : null);
}

void main() {
  final PkgmgrPlatform initialPlatform = PkgmgrPlatform.instance;

  test('$MethodChannelPkgmgr is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPkgmgr>());
  });

  group('with mock platform', () {
    late Pkgmgr pkgmgrPlugin;
    late MockPkgmgrPlatform fakePlatform;

    setUp(() {
      pkgmgrPlugin = Pkgmgr();
      fakePlatform = MockPkgmgrPlatform();
      PkgmgrPlatform.instance = fakePlatform;
    });

    test('getPlatformVersion', () async {
      expect(await pkgmgrPlugin.getPlatformVersion(), '42');
    });

    test('getInstalledApps returns list of AppInfo with icons', () async {
      final apps = await pkgmgrPlugin.getInstalledApps();
      expect(apps, hasLength(1));
      expect(apps.first.name, 'Test App');
      expect(apps.first.packageId, 'com.example.test');
      expect(apps.first.iconBase64, 'aGVsbG8=');
    });

    test('getInstalledAppsInfo returns list of AppInfo without icons',
        () async {
      final apps = await pkgmgrPlugin.getInstalledAppsInfo();
      expect(apps, hasLength(1));
      expect(apps.first.name, 'Test App');
      expect(apps.first.packageId, 'com.example.test');
      expect(apps.first.iconBase64, isNull);
    });

    test('getAppIcon returns icon for known package', () async {
      final icon = await pkgmgrPlugin.getAppIcon('com.example.test');
      expect(icon, 'aGVsbG8=');
    });

    test('getAppIcon returns null for unknown package', () async {
      final icon = await pkgmgrPlugin.getAppIcon('com.unknown.app');
      expect(icon, isNull);
    });

    test('getInstalledApps with showSystem=true', () async {
      final apps = await pkgmgrPlugin.getInstalledApps(showSystem: true);
      expect(apps, isA<List<AppInfo>>());
    });

    test('getInstalledAppsInfo with showSystem=true', () async {
      final apps = await pkgmgrPlugin.getInstalledAppsInfo(showSystem: true);
      expect(apps, isA<List<AppInfo>>());
    });
  });
}
