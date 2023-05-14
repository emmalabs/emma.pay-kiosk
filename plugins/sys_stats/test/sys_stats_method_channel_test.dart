import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sys_stats/sys_stats_method_channel.dart';

void main() {
  MethodChannelSysStats platform = MethodChannelSysStats();
  const MethodChannel channel = MethodChannel('sys_stats');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
