import FlutterMacOS
import Foundation

public class PkgmgrPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pkgmgr", binaryMessenger: registrar.messenger)
    let instance = PkgmgrPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterError(code: "UNIMPLEMENTED", message: "macOS is not supported yet", details: nil))
  }
}
