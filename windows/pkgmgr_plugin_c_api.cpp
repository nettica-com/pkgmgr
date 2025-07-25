#include "include/pkgmgr/pkgmgr_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "pkgmgr_plugin.h"

void PkgmgrPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pkgmgr::PkgmgrPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
