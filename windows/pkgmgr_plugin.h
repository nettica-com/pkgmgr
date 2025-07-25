#ifndef FLUTTER_PLUGIN_PKGMGR_PLUGIN_H_
#define FLUTTER_PLUGIN_PKGMGR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace pkgmgr {

class PkgmgrPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PkgmgrPlugin();

  virtual ~PkgmgrPlugin();

  // Disallow copy and assign.
  PkgmgrPlugin(const PkgmgrPlugin&) = delete;
  PkgmgrPlugin& operator=(const PkgmgrPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace pkgmgr

#endif  // FLUTTER_PLUGIN_PKGMGR_PLUGIN_H_
