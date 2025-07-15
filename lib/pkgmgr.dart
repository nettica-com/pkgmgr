
import 'pkgmgr_platform_interface.dart';


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

  Future<List<AppInfo>> getInstalledApps({bool showSystem = false}) async {
    final apps = await PkgmgrPlatform.instance.getInstalledApps(showSystem: showSystem);
    return (apps as List).map((e) => AppInfo.fromMap(e)).toList();
  }
}
