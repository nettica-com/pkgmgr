
#include <windows.h>
#include "flutter/plugin_registrar_windows.h"
#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"

namespace pkgmgr {

class PkgmgrPlugin : public flutter::Plugin {
 public:

 static void PkgmgrPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "pkgmgr",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<PkgmgrPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

  PkgmgrPlugin() {}
  virtual ~PkgmgrPlugin() {}

  // Called when a method is invoked on this plugin's channel
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (call.method_name().compare("getInstalledApps") == 0) {
      result->Error("UNIMPLEMENTED", "Windows is not supported yet");
    } else if (call.method_name().compare("getPlatformVersion") == 0) {
      result->Success("Windows");
    } else {
      result->NotImplemented();
    }
  }
};

}  // namespace pkgmgr

extern "C" __declspec(dllexport) void PkgmgrPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrar *registrar) {
  pkgmgr::PkgmgrPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
