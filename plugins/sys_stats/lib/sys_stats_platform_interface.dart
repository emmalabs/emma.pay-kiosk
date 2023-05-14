import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sys_stats_method_channel.dart';

abstract class SysStatsPlatform extends PlatformInterface {
  /// Constructs a SysStatsPlatform.
  SysStatsPlatform() : super(token: _token);

  static final Object _token = Object();

  static SysStatsPlatform _instance = MethodChannelSysStats();

  /// The default instance of [SysStatsPlatform] to use.
  ///
  /// Defaults to [MethodChannelSysStats].
  static SysStatsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SysStatsPlatform] when
  /// they register themselves.
  static set instance(SysStatsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<Object?, Object?>?> getStats() async {
    throw UnimplementedError('getStats() has not been implemented.');
  }
}
