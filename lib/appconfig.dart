import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppConfig {
  final int port;

  AppConfig({required this.port});
}

class AppConfigSingleton {
  static final AppConfigSingleton _singleton = AppConfigSingleton._internal();
  AppConfig _config = AppConfig(port: 88);

  factory AppConfigSingleton() {
    return _singleton;
  }

  AppConfigSingleton._internal();

  Future<void> init() async {
    sqfliteFfiInit();

    final database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE app_config(key TEXT PRIMARY KEY, value TEXT)',
        );
      },
      version: 1,
    );

    final List<Map<String, dynamic>> maps = await database.query('app_config');

    if (maps.isNotEmpty) {
      final port = maps.firstWhere((map) => map['key'] == 'port')['value'];

      _config = AppConfig(
        port: port,
      );
    } else {
      await database.transaction((txn) async {
        await txn.insert(
          'app_config',
          {'key': 'port', 'value': _config.port},
        );
      });
    }
  }

  AppConfig get config => _config;

  Future<void> updateConfig(AppConfig config) async {
    _config = config;

    final database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      version: 1,
    );

    await database.transaction((txn) async {
      await txn.update(
        'app_config',
        {'value': config.port},
        where: 'key = ?',
        whereArgs: ['port'],
      );
    });
  }
}
