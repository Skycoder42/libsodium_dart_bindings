//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <sodium_libs/sodium_libs_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) sodium_libs_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SodiumLibsPlugin");
  sodium_libs_plugin_register_with_registrar(sodium_libs_registrar);
}
