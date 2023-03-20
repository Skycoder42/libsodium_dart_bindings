#include "sodium_libs_plugin.h"

namespace sodium_libs {

// static
void SodiumLibsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<SodiumLibsPlugin>();
  registrar->AddPlugin(std::move(plugin));
}

SodiumLibsPlugin::SodiumLibsPlugin() {}

SodiumLibsPlugin::~SodiumLibsPlugin() {}

}  // namespace sodium_libs
