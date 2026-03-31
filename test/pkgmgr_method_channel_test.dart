import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkgmgr/pkgmgr_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPkgmgr platform = MethodChannelPkgmgr();
  const MethodChannel channel = MethodChannel('pkgmgr');

  final List<Map<String, dynamic>> fakeAppsWithIcons = [
    {'name': 'Test App', 'package': 'com.example.test', 'icon': 'aGVsbG8='},
  ];

  final List<Map<String, dynamic>> fakeAppsWithoutIcons = [
    {'name': 'Test App', 'package': 'com.example.test', 'icon': null},
  ];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return '42';
            case 'getInstalledApps':
              return fakeAppsWithIcons;
            case 'getInstalledAppsInfo':
              return fakeAppsWithoutIcons;
            case 'getAppIcon':
              final packageId =
                  (methodCall.arguments as Map)['packageId'] as String;
              return packageId == 'com.example.test' ? 'aGVsbG8=' : null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getInstalledApps returns list with icons', () async {
    final apps = await platform.getInstalledApps();
    expect(apps, hasLength(1));
    final app = apps.first as Map;
    expect(app['name'], 'Test App');
    expect(app['package'], 'com.example.test');
    expect(app['icon'], 'aGVsbG8=');
  });

  test('getInstalledAppsInfo returns list without icons', () async {
    final apps = await platform.getInstalledAppsInfo();
    expect(apps, hasLength(1));
    final app = apps.first as Map;
    expect(app['name'], 'Test App');
    expect(app['package'], 'com.example.test');
    expect(app['icon'], isNull);
  });

  test('getAppIcon returns icon for known package', () async {
    final icon = await platform.getAppIcon('com.example.test');
    expect(icon, 'aGVsbG8=');
  });

  test('getAppIcon returns null for unknown package', () async {
    final icon = await platform.getAppIcon('com.unknown.app');
    expect(icon, isNull);
  });
}
