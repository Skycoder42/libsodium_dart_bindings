#include "include/sodium_libs/sodium_libs_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace
{

  class SodiumLibsPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
    {
      auto plugin = std::make_unique<SodiumLibsPlugin>();
      registrar->AddPlugin(std::move(plugin));
    }
  };

} // namespace

void SodiumLibsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  SodiumLibsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
