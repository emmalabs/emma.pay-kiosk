import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sys_stats/sys_stats.dart';

class SystemInfo extends StatefulWidget {
  const SystemInfo({super.key});

  @override
  State<SystemInfo> createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  final sysStats = SysStats();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  double? _cpuUsage = 0;
  double? _memUsage = 0;
  late Timer updateTimer;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();

    initConnectivity();

    _initStats();
    updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _initStats();
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
            child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("App Info", style: Theme.of(context).textTheme.headlineSmall)),
                  ),
                  DataTable(
                    headingRowHeight: 0,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Value')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Name')),
                        if (_packageInfo != null) DataCell(Text(_packageInfo!.appName)) else const DataCell(Text('')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Package')),
                        if (_packageInfo != null) DataCell(Text(_packageInfo!.packageName)) else const DataCell(Text('')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Version')),
                        if (_packageInfo != null) DataCell(Text(_packageInfo!.version)) else const DataCell(Text('')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Build')),
                        if (_packageInfo != null) DataCell(Text(_packageInfo!.buildNumber)) else const DataCell(Text('')),
                      ]),
                    ],
                  ),
                ],
              )),
              Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("System Info", style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  DataTable(
                    headingRowHeight: 0,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Value')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('CPU Usage')),
                        DataCell(Text('$_cpuUsage%')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Memory Usage')),
                        DataCell(Text('$_memUsage%')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Connection Status')),
                        DataCell(Text('$_connectionStatus')),
                      ]),
                    ],
                  ),
                ],
              )),
            ],
          ),
        )),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  void _initStats() async {
    PackageInfo p;

    final stats = await sysStats.getStats();
    final statsMap = Map<String, double>.from(stats!.cast<Object, Object>());
    p = await PackageInfo.fromPlatform();

    setState(() {
      _cpuUsage = (statsMap['cpu']! * 100);
      _memUsage = statsMap['memory'];
      _packageInfo = p;
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
}
