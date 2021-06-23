#include "include/sodium_libs_windows/sodium_libs_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace
{

  class SodiumLibsWindowsPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
    {
      auto plugin = std::make_unique<SodiumLibsWindowsPlugin>();
      registrar->AddPlugin(std::move(plugin));
    }
  };

} // namespace

void SodiumLibsWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  SodiumLibsWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
