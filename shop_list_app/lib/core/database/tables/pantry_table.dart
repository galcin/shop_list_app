import 'package:drift/drift.dart';

import 'product_category_table.dart';
import 'product_table.dart';

class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn? get productId => integer().nullable().references(Products, #id)();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  IntColumn get categoryId => integer().references(ProductCategories, #id)();
  DateTimeColumn? get expiryDate => dateTime().nullable()();
  DateTimeColumn get purchasedDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn? get location => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
