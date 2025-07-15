import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pkgmgr_platform_interface.dart';

/// An implementation of [PkgmgrPlatform] that uses method channels.
class MethodChannelPkgmgr extends PkgmgrPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pkgmgr');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<List<Object?>> getInstalledApps({bool showSystem = false}) async {
    final apps = await methodChannel.invokeMethod<List<dynamic>>(
      "getInstalledApps",
      {"showSystem": showSystem},
    );
    return apps ?? [];
  }
}
