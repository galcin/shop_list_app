import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/database/seeder/seed_data.dart'
    show normalizeSeedName;
import 'package:shop_list_app/features/products/domain/entities/product.dart'
    as model;
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  // ── Queries ────────────────────────────────────────────────────────────────

  @override
  Future<List<model.Product>> getAllProducts() async {
    final rows = await (_db.select(_db.products)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<model.Product?> getProductById(int id) async {
    final row = await (_db.select(_db.products)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<List<model.Product>> getProductsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (_db.select(_db.products)..where((t) => t.id.isIn(ids)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<model.Product>> getProductsByCategory(int categoryId) async {
    final rows = await (_db.select(_db.products)
          ..where((t) => t.productCategoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<model.Product>> searchProducts(String query) async {
    final rows = await (_db.select(_db.products)
          ..where((t) => t.name.contains(query) | t.aliases.contains(query))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<model.Product?> findByNameOrAlias(String name) async {
    final key = normalizeSeedName(name);
    if (key.isEmpty) return null;
    final candidates = <String>{key};
    if (key.endsWith('s')) candidates.add(key.substring(0, key.length - 1));
    candidates.add('${key}s');

    // Cheap pre-filter in SQL, exact comparison in Dart (normalisation is
    // not expressible in SQLite without custom functions).
    final rows = await (_db.select(_db.products)
          ..where((t) => Expression.or([
                for (final c in candidates) t.name.lower().equals(c),
                for (final c in candidates) t.aliases.contains(c),
              ])))
        .get();
    for (final row in rows) {
      final keys = {
        normalizeSeedName(row.name),
        for (final a in (row.aliases ?? '').split('|')) normalizeSeedName(a),
      };
      if (keys.any(candidates.contains)) return _fromRow(row);
    }
    return null;
  }

  @override
  Future<int> getProductCount() async {
    final count = _db.products.id.count();
    final row = await (_db.selectOnly(_db.products)..addColumns([count]))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<int> getProductCountByCategory(int categoryId) async {
    final count = _db.products.id.count();
    final row = await (_db.selectOnly(_db.products)
          ..addColumns([count])
          ..where(_db.products.productCategoryId.equals(categoryId)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<bool> productExists(String name) async {
    final row = await (_db.select(_db.products)
          ..where((t) => t.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  @override
  Future<int> addProduct(model.Product product) {
    final now = DateTime.now();
    return _db.into(_db.products).insert(
          ProductsCompanion.insert(
            name: product.name?.trim() ?? '',
            defaultUnit: Value(product.defaultUnit),
            photo: Value(_cleanPhoto(product.photo)),
            aliases: Value(_joinAliases(product.aliases)),
            productCategoryId: product.productCategoryId ?? 1,
            isBuiltIn: Value(product.isBuiltIn),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<bool> updateProduct(model.Product product) async {
    if (product.id == null) return false;
    final updated = await (_db.update(_db.products)
          ..where((t) => t.id.equals(product.id!)))
        .write(ProductsCompanion(
      name: Value(product.name?.trim() ?? ''),
      defaultUnit: Value(product.defaultUnit),
      photo: Value(_cleanPhoto(product.photo)),
      aliases: Value(_joinAliases(product.aliases)),
      productCategoryId: Value(product.productCategoryId ?? 1),
      updatedAt: Value(DateTime.now()),
    ));
    return updated > 0;
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final deleted =
        await (_db.delete(_db.products)..where((t) => t.id.equals(id))).go();
    return deleted > 0;
  }

  @override
  Future<int> deleteAllProducts() => _db.delete(_db.products).go();

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _cleanPhoto(String? photo) =>
      (photo == null || photo.trim().isEmpty) ? null : photo.trim();

  String? _joinAliases(List<String> aliases) {
    final cleaned = aliases.map((a) => a.trim()).where((a) => a.isNotEmpty);
    return cleaned.isEmpty ? null : cleaned.join('|');
  }

  model.Product _fromRow(Product row) => model.Product(
        id: row.id,
        name: row.name,
        defaultUnit: row.defaultUnit,
        photo: row.photo,
        aliases: (row.aliases ?? '')
            .split('|')
            .where((a) => a.isNotEmpty)
            .toList(),
        productCategoryId: row.productCategoryId,
        isBuiltIn: row.isBuiltIn,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
