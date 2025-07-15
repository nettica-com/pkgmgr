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
}
