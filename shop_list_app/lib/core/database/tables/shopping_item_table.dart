import 'package:drift/drift.dart';
import 'shopping_list_table.dart';
import 'product_table.dart';
import 'product_category_table.dart';

/// Stores items belonging to a shopping list.
class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// FK to the parent shopping list.
  IntColumn get listId =>
      integer().references(ShoppingLists, #id, onDelete: KeyAction.cascade)();

  /// Optional FK to a product in the catalogue.
  IntColumn get productId => integer()
      .nullable()
      .references(Products, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();

  /// Optional FK to a product category.
  IntColumn get categoryId => integer()
      .nullable()
      .references(ProductCategories, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
