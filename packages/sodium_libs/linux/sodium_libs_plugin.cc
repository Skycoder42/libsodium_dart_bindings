#include "include/sodium_libs/sodium_libs_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define SODIUM_LIBS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), sodium_libs_plugin_get_type(), \
                              SodiumLibsPlugin))

struct _SodiumLibsPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(SodiumLibsPlugin, sodium_libs_plugin, g_object_get_type())

static void sodium_libs_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(sodium_libs_plugin_parent_class)->dispose(object);
}

static void sodium_libs_plugin_class_init(SodiumLibsPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = sodium_libs_plugin_dispose;
}

static void sodium_libs_plugin_init(SodiumLibsPlugin *self) {}

void sodium_libs_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  SodiumLibsPlugin *plugin = SODIUM_LIBS_PLUGIN(
      g_object_new(sodium_libs_plugin_get_type(), nullptr));
  g_object_unref(plugin);
}
