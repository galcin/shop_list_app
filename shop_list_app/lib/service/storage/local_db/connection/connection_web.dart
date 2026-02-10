import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  // Use WebDatabase for web platforms - stores data in IndexedDB
  // This doesn't require sqlite3.wasm and works out of the box
  return WebDatabase('shop_list_db', logStatements: true);
}
