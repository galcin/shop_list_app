import 'package:drift/drift.dart';

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get units => text().nullable()();
}
