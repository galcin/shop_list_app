import 'package:drift/drift.dart';
import 'product_category_table.dart';

/// Product catalogue. A row describes *what* a product is (name, default
/// unit, category, picture), never how much of it the user owns — that lives
/// in the pantry and shopping list tables which reference this one.
@TableIndex(name: 'idx_products_name', columns: {#name})
@TableIndex(name: 'idx_products_category', columns: {#productCategoryId})
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Unit suggested when the product is added to a list or recipe.
  TextColumn get defaultUnit => text().withDefault(const Constant('pcs'))();

  /// Emoji, `assets/...` path or local file path. Null when none is set.
  TextColumn get photo => text().nullable()();

  /// Pipe-separated lowercase alternative names, e.g. `carrot|morcov`.
  TextColumn get aliases => text().nullable()();
  IntColumn get productCategoryId =>
      integer().references(ProductCategories, #id)();

  /// `true` for rows shipped with the app; they are refreshed by seed updates.
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
