import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';

abstract class IProductCategoryRepository {
  /// Reactive stream of all categories ordered by [sortOrder].
  Stream<Either<Failure, List<ProductCategory>>> watchAll();

  /// Insert or update a category. Returns the saved entity.
  Future<Either<Failure, ProductCategory>> save(ProductCategory category);

  /// Update an existing category.
  Future<Either<Failure, ProductCategory>> update(ProductCategory category);

  /// Delete a category by [id]. Returns [ConflictFailure] if products are assigned.
  Future<Either<Failure, bool>> delete(int id);

  /// Bulk-update sortOrder for the given ordered list of ids.
  Future<Either<Failure, bool>> reorder(List<int> orderedIds);

  /// Get category count for a given [categoryId] in products table.
  Future<int> countProductsForCategory(int categoryId);

  // -- Legacy helpers (still used by existing pages) ----------------------
  Future<List<ProductCategory>> getAllCategories();
  Future<ProductCategory?> getCategoryById(int id);
  Future<int> addCategory(ProductCategory category);
  Future<bool> updateCategory(ProductCategory category);
  Future<bool> deleteCategory(int id);
}
