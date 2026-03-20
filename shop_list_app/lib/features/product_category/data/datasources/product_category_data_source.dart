import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';

/// Drift DAO for [ProductCategories].
///
/// Provides reactive streams and all CRUD primitives.
/// All queries are ordered by [sortOrder] ascending.
class ProductCategoryDataSource {
  ProductCategoryDataSource(this._db);

  final AppDatabase _db;

  // ── Reactive ────────────────────────────────────────────────────────────────

  /// Emits the full list whenever any row changes.
  Stream<List<ProductCategory>> watchAll() {
    return (_db.select(_db.productCategories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  // ── Queries ─────────────────────────────────────────────────────────────────

  Future<List<ProductCategory>> getAll() {
    return (_db.select(_db.productCategories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<ProductCategory?> getById(int id) {
    return (_db.select(_db.productCategories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Count products assigned to [categoryId].
  Future<int> countProductsForCategory(int categoryId) async {
    final rows = await (_db.select(_db.products)
          ..where((t) => t.productCategoryId.equals(categoryId)))
        .get();
    return rows.length;
  }

  // ── Mutations ────────────────────────────────────────────────────────────────

  /// Insert a new category row. Returns the auto-generated id.
  Future<int> insert(ProductCategoriesCompanion companion) {
    return _db.into(_db.productCategories).insert(companion);
  }

  /// Update a category row. Returns the number of affected rows.
  Future<int> updateById(int id, ProductCategoriesCompanion companion) {
    return (_db.update(_db.productCategories)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// Delete a category row. Returns the number of deleted rows.
  Future<int> deleteById(int id) {
    return (_db.delete(_db.productCategories)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Bulk-update [sortOrder] in a single transaction.
  Future<void> bulkUpdateSortOrder(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (int i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.productCategories)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(ProductCategoriesCompanion(sortOrder: Value(i)));
      }
    });
  }
}
