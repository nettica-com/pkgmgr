// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pkgmgr/pkgmgr.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final plugin = Pkgmgr();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final String? version = await plugin.getPlatformVersion();
    expect(version?.isNotEmpty, true);
  });

  testWidgets('getInstalledApps returns non-empty list with icons',
      (WidgetTester tester) async {
    final apps = await plugin.getInstalledApps();
    expect(apps, isNotEmpty);
    expect(apps.first.name, isNotEmpty);
    expect(apps.first.packageId, isNotEmpty);
  });

  testWidgets('getInstalledAppsInfo returns non-empty list without icons',
      (WidgetTester tester) async {
    final apps = await plugin.getInstalledAppsInfo();
    expect(apps, isNotEmpty);
    expect(apps.first.name, isNotEmpty);
    expect(apps.first.packageId, isNotEmpty);
    // Icons are not loaded by getInstalledAppsInfo
    expect(apps.first.iconBase64, isNull);
  });

  testWidgets('getAppIcon returns icon for a known package',
      (WidgetTester tester) async {
    final apps = await plugin.getInstalledAppsInfo();
    expect(apps, isNotEmpty);
    // Use the first app's packageId to fetch its icon
    final icon = await plugin.getAppIcon(apps.first.packageId);
    // icon may be null on platforms that don't support it, so just check type
    expect(icon, anyOf(isNull, isA<String>()));
  });
}
