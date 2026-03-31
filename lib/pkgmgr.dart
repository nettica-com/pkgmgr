import 'pkgmgr_platform_interface.dart';

///
/// Represents information about an installed app.
///
class AppInfo {
  final String name;
  final String packageId;
  final String? iconBase64;

  AppInfo({required this.name, required this.packageId, this.iconBase64});

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      name: map['name'] as String,
      packageId: map['package'] as String,
      iconBase64: map['icon'] as String?,
    );
  }
}

class Pkgmgr {
  Future<String?> getPlatformVersion() {
    return PkgmgrPlatform.instance.getPlatformVersion();
  }

  /// Returns a list of all installed apps on the device.  Requires QUERY_ALL_PACKAGES permission.
  ///
  /// If [showSystem] is true, system apps are included.
  /// Each app includes its name, packageId, and iconBase64 (as base64).
  /// See example for typical usage.
  Future<List<AppInfo>> getInstalledApps({bool showSystem = false}) async {
    final apps = await PkgmgrPlatform.instance.getInstalledApps(
      showSystem: showSystem,
    );
    return (apps as List).map((e) => AppInfo.fromMap(e)).toList();
  }

  /// Returns a list of all installed apps without icons. Much faster than
  /// [getInstalledApps] since no icon processing is performed. Each app's
  /// [AppInfo.iconBase64] will be null. Use [getAppIcon] to load icons
  /// on demand as needed (e.g. as items scroll into view).
  Future<List<AppInfo>> getInstalledAppsInfo({bool showSystem = false}) async {
    final apps = await PkgmgrPlatform.instance.getInstalledAppsInfo(
      showSystem: showSystem,
    );
    return (apps as List).map((e) => AppInfo.fromMap(e)).toList();
  }

  /// Returns the base64-encoded PNG icon for the app with the given [packageId],
  /// scaled to 96x96 pixels. Returns null if the app is not found or the icon
  /// cannot be loaded. Only supported on Android; returns null on other platforms.
  Future<String?> getAppIcon(String packageId) {
    return PkgmgrPlatform.instance.getAppIcon(packageId);
  }
}
