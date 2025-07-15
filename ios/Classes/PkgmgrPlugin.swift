import Flutter
import UIKit

public class PkgmgrPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pkgmgr", binaryMessenger: registrar.messenger())
    let instance = PkgmgrPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getInstalledApps":
      result([]) // Return empty list on iOS
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
