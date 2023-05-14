import 'sys_stats_platform_interface.dart';

class SysStats {
  Future<String?> getPlatformVersion() {
    return SysStatsPlatform.instance.getPlatformVersion();
  }

  Future<Map<Object?, Object?>?> getStats() {
    return SysStatsPlatform.instance.getStats();
  }
}
