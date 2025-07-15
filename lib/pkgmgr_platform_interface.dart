import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pkgmgr_method_channel.dart';

abstract class PkgmgrPlatform extends PlatformInterface {
  /// Constructs a PkgmgrPlatform.
  PkgmgrPlatform() : super(token: _token);

  static final Object _token = Object();

  static PkgmgrPlatform _instance = MethodChannelPkgmgr();

  /// The default instance of [PkgmgrPlatform] to use.
  ///
  /// Defaults to [MethodChannelPkgmgr].
  static PkgmgrPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PkgmgrPlatform] when
  /// they register themselves.
  static set instance(PkgmgrPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Object?>> getInstalledApps({bool showSystem = false}) {
    throw UnimplementedError('getInstalledApps() has not been implemented.');
  }
}
