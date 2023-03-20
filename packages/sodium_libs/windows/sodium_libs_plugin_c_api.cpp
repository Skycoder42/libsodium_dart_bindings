#include "include/sodium_libs/sodium_libs_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sodium_libs_plugin.h"

void SodiumLibsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sodium_libs::SodiumLibsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
