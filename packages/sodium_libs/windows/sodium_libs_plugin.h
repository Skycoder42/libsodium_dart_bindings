#ifndef FLUTTER_PLUGIN_SODIUM_LIBS_PLUGIN_H_
#define FLUTTER_PLUGIN_SODIUM_LIBS_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

namespace sodium_libs {

class SodiumLibsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SodiumLibsPlugin();

  virtual ~SodiumLibsPlugin();

  // Disallow copy and assign.
  SodiumLibsPlugin(const SodiumLibsPlugin&) = delete;
  SodiumLibsPlugin& operator=(const SodiumLibsPlugin&) = delete;
};

}  // namespace sodium_libs

#endif  // FLUTTER_PLUGIN_SODIUM_LIBS_PLUGIN_H_
