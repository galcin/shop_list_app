import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart' as model;
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final AppDatabase _database;

  ProductRepository(this._database);

  // Get all products
  @override
  Future<List<model.Product>> getAllProducts() async {
    final products = await _database.select(_database.products).get();
    return products.map((row) => _productFromRow(row)).toList();
  }

  // Get product by ID
  @override
  Future<model.Product?> getProductById(int id) async {
    final product = await (_database.select(_database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return product != null ? _productFromRow(product) : null;
  }

  // Get products by category
  @override
  Future<List<model.Product>> getProductsByCategory(int categoryId) async {
    final products = await (_database.select(_database.products)
          ..where((tbl) => tbl.productCategoryId.equals(categoryId)))
        .get();
    return products.map((row) => _productFromRow(row)).toList();
  }

  // Get expiring products (within specified days)
  @override
  Future<List<model.Product>> getExpiringProducts(int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    final products = await (_database.select(_database.products)
          ..where((tbl) => tbl.expirationDate.isBetweenValues(now, futureDate))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.expirationDate)]))
        .get();
    return products.map((row) => _productFromRow(row)).toList();
  }

  // Get expired products
  @override
  Future<List<model.Product>> getExpiredProducts() async {
    final now = DateTime.now();

    final products = await (_database.select(_database.products)
          ..where((tbl) => tbl.expirationDate.isSmallerThanValue(now))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.expirationDate)]))
        .get();
    return products.map((row) => _productFromRow(row)).toList();
  }

  // Search products by name
  @override
  Future<List<model.Product>> searchProducts(String query) async {
    final products = await (_database.select(_database.products)
          ..where((tbl) => tbl.name.contains(query)))
        .get();
    return products.map((row) => _productFromRow(row)).toList();
  }

  // Add a new product
  @override
  Future<int> addProduct(model.Product product) async {
    return await _database.into(_database.products).insert(
          ProductsCompanion.insert(
            name: product.name ?? '',
            quantity: product.quantity ?? 0.0,
            units: product.units ?? '',
            photo: product.photo ?? '',
            expirationDate: product.expirationDate ?? DateTime.now(),
            productCategoryId: product.productCategoryId ?? 1,
          ),
        );
  }

  // Update an existing product
  @override
  Future<bool> updateProduct(model.Product product) async {
    if (product.id == null) return false;

    final updated = await (_database.update(_database.products)
          ..where((tbl) => tbl.id.equals(product.id!)))
        .write(
      ProductsCompanion(
        name: Value(product.name ?? ''),
        quantity: Value(product.quantity ?? 0.0),
        units: Value(product.units ?? ''),
        photo: Value(product.photo ?? ''),
        expirationDate: Value(product.expirationDate ?? DateTime.now()),
        productCategoryId: Value(product.productCategoryId ?? 1),
      ),
    );
    return updated > 0;
  }

  // Delete a product
  @override
  Future<bool> deleteProduct(int id) async {
    final deleted = await (_database.delete(_database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    return deleted > 0;
  }

  // Delete all products
  @override
  Future<int> deleteAllProducts() async {
    return await _database.delete(_database.products).go();
  }

  // Get product count
  @override
  Future<int> getProductCount() async {
    final count = await _database.select(_database.products).get();
    return count.length;
  }

  // Get product count by category
  @override
  Future<int> getProductCountByCategory(int categoryId) async {
    final count = await (_database.select(_database.products)
          ..where((tbl) => tbl.productCategoryId.equals(categoryId)))
        .get();
    return count.length;
  }

  // Check if product with name exists
  @override
  Future<bool> productExists(String name) async {
    final product = await (_database.select(_database.products)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return product != null;
  }

  // Convert database row to Product model
  model.Product _productFromRow(Product row) {
    return model.Product(
      id: row.id,
      name: row.name,
      quantity: row.quantity,
      units: row.units,
      photo: row.photo,
      expirationDate: row.expirationDate,
      productCategoryId: row.productCategoryId,
    );
  }
}
