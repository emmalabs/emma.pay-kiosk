//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <sys_stats/sys_stats_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) sys_stats_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SysStatsPlugin");
  sys_stats_plugin_register_with_registrar(sys_stats_registrar);
}
