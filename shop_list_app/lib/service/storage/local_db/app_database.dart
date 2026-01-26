import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Ingredients])
class AppDatabase extends _$AppDatabase {
  static AppDatabase instance() => AppDatabase();

  AppDatabase() : super(_openConnection());

  Future<List<Ingredient>> getAllIngredients() => select(ingredients).get();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
