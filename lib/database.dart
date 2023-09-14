import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

final _uuid = Uuid();

class AppConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text()();
  TextColumn get value => text()();
}

class AppTransactions extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v1())();

  RealColumn get amount => real()();
  RealColumn get paid => real().withDefault(const Constant(0))();
  RealColumn get change => real().withDefault(const Constant(0))();
  TextColumn get currency => text()();

  TextColumn get method => text().nullable()();
  TextColumn get status => text()();
  TextColumn get description => text().nullable()();

  TextColumn get metadata => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get paidAt => dateTime().withDefault(currentDateAndTime).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppTransactionEvents extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v1())();

  TextColumn get transactionId => text()();
  TextColumn get type => text().nullable()();
  TextColumn get status => text().nullable()();

  TextColumn get metadata => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [AppConfigs, AppTransactions, AppTransactionEvents])
class AppDatabase extends _$AppDatabase {
  // we tell the database where to store the data with this constructor
  AppDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;

  Future<String> getConfigValue(String key) async {
    AppConfig cfg =
        await (select(appConfigs)..where((t) => t.key.equals(key))).getSingle().onError((error, stackTrace) {
      return Future.value(const AppConfig(id: 0, key: '', value: ''));
    });
    return cfg.value;
  }

  Future<AppTransaction> addTransaction(AppTransactionsCompanion entry) async {
    return into(appTransactions).insertReturning(entry);
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    print(file.absolute.path);
    return NativeDatabase.createInBackground(file);
  });
}
