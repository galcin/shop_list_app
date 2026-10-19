import 'package:drift/drift.dart';

/// Small key/value store for database-level bookkeeping such as the seed
/// data version. Kept in the database (not shared preferences) so the value
/// travels with the file on backup and restore.
@DataClassName('AppMetaEntry')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Keys used in [AppMeta].
class AppMetaKeys {
  AppMetaKeys._();

  /// Version of the bundled seed data last applied to this database.
  static const String seedVersion = 'seed_version';
}
