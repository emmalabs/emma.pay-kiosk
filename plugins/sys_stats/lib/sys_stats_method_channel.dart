import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sys_stats_platform_interface.dart';

/// An implementation of [SysStatsPlatform] that uses method channels.
class MethodChannelSysStats extends SysStatsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sys_stats');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<Object?, Object?>?> getStats() async {
    final stats = await methodChannel.invokeMethod<Map<Object?, Object?>>('getStats');
    return stats;
  }
}
