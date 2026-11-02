import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    // IMPORTANT: use a persistent, app-owned directory — never the OS temp
    // directory. Temp dirs can be cleared or atomically relocated by the OS
    // (Windows Storage Sense / Known Folder Move, iOS purging temp files,
    // antivirus/cloud-sync tools, etc.) while the app holds the DB open,
    // which raises `SqliteException(1032) SQLITE_READONLY_DBMOVED` ("attempt
    // to write a readonly database") on the next write.
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'shop_list_db.db'));
    return NativeDatabase.createInBackground(file);
  });
}
