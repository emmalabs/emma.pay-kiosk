#include "include/sys_stats/sys_stats_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sys_stats_plugin.h"

void SysStatsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sys_stats::SysStatsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
