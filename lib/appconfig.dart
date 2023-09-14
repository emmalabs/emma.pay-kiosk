import 'package:uuid/uuid.dart';

import 'database.dart';

class Config {
  int port;
  String currency = 'EUR';
  Uuid uuid = const Uuid();

  Config({required this.port});
}

class AppConfigSingleton {
  static final AppConfigSingleton _singleton = AppConfigSingleton._internal();
  final _config = Config(port: 88);
  final _db = AppDatabase();

  factory AppConfigSingleton() {
    return _singleton;
  }

  AppConfigSingleton._internal();

  Future<void> init() async {
    int port = int.tryParse(await _db.getConfigValue('port')) ?? 0;
    if (port > 0) _config.port = port;
  }

  Config get config => _config;
  AppDatabase get db => _db;
}
