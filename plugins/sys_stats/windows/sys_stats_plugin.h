#ifndef FLUTTER_PLUGIN_SYS_STATS_PLUGIN_H_
#define FLUTTER_PLUGIN_SYS_STATS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace sys_stats {

class SysStatsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SysStatsPlugin();

  virtual ~SysStatsPlugin();

  // Disallow copy and assign.
  SysStatsPlugin(const SysStatsPlugin&) = delete;
  SysStatsPlugin& operator=(const SysStatsPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace sys_stats

#endif  // FLUTTER_PLUGIN_SYS_STATS_PLUGIN_H_
