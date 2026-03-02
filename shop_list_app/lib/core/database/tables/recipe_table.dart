import 'package:drift/drift.dart';

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get instructions => text().nullable()();
  IntColumn get prepTime => integer().nullable()();
  BoolColumn get favorite => boolean().nullable()();
}
