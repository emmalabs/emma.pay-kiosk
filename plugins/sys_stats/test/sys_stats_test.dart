import 'package:flutter_test/flutter_test.dart';
import 'package:sys_stats/sys_stats.dart';
import 'package:sys_stats/sys_stats_platform_interface.dart';
import 'package:sys_stats/sys_stats_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSysStatsPlatform
    with MockPlatformInterfaceMixin
    implements SysStatsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SysStatsPlatform initialPlatform = SysStatsPlatform.instance;

  test('$MethodChannelSysStats is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSysStats>());
  });

  test('getPlatformVersion', () async {
    SysStats sysStatsPlugin = SysStats();
    MockSysStatsPlatform fakePlatform = MockSysStatsPlatform();
    SysStatsPlatform.instance = fakePlatform;

    expect(await sysStatsPlugin.getPlatformVersion(), '42');
  });
}
