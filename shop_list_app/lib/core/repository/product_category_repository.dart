import 'package:drift/drift.dart';
import '../../service/storage/local_db/app_database.dart';
import '../../service/models/product_category.dart' as model;

class ProductCategoryRepository {
  final AppDatabase _database;

  ProductCategoryRepository(this._database);

  // Get all product categories
  Future<List<model.ProductCategory>> getAllCategories() async {
    final categories =
        await _database.select(_database.productCategories).get();
    return categories.map((row) => _categoryFromRow(row)).toList();
  }

  // Get category by ID
  Future<model.ProductCategory?> getCategoryById(int id) async {
    final category = await (_database.select(_database.productCategories)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return category != null ? _categoryFromRow(category) : null;
  }

  // Get category by name
  Future<model.ProductCategory?> getCategoryByName(String name) async {
    final category = await (_database.select(_database.productCategories)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return category != null ? _categoryFromRow(category) : null;
  }

  // Search categories by name
  Future<List<model.ProductCategory>> searchCategories(String query) async {
    final categories = await (_database.select(_database.productCategories)
          ..where((tbl) => tbl.name.contains(query)))
        .get();
    return categories.map((row) => _categoryFromRow(row)).toList();
  }

  // Add a new category
  Future<int> addCategory(model.ProductCategory category) async {
    return await _database.into(_database.productCategories).insert(
          ProductCategoriesCompanion.insert(
            name: category.name,
            photo: Value(category.photo),
          ),
        );
  }

  // Update an existing category
  Future<bool> updateCategory(model.ProductCategory category) async {
    final updated = await (_database.update(_database.productCategories)
          ..where((tbl) => tbl.id.equals(category.id)))
        .write(
      ProductCategoriesCompanion(
        name: Value(category.name),
        photo: Value(category.photo),
      ),
    );
    return updated > 0;
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    final deleted = await (_database.delete(_database.productCategories)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    return deleted > 0;
  }

  // Check if category with name exists
  Future<bool> categoryExists(String name) async {
    final category = await (_database.select(_database.productCategories)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return category != null;
  }

  // Get category count
  Future<int> getCategoryCount() async {
    final count = await _database.select(_database.productCategories).get();
    return count.length;
  }

  // Convert database row to ProductCategory model
  model.ProductCategory _categoryFromRow(ProductCategory row) {
    return model.ProductCategory(
      id: row.id,
      name: row.name,
      photo: row.photo,
    );
  }
}
