import '../../../service/models/product_category.dart';

abstract class IProductCategoryRepository {
  // Get all product categories
  Future<List<ProductCategory>> getAllCategories();

  // Get category by ID
  Future<ProductCategory?> getCategoryById(int id);

  // Get category by name
  Future<ProductCategory?> getCategoryByName(String name);

  // Search categories by name
  Future<List<ProductCategory>> searchCategories(String query);

  // Add a new category
  Future<int> addCategory(ProductCategory category);

  // Update an existing category
  Future<bool> updateCategory(ProductCategory category);

  // Delete a category
  Future<bool> deleteCategory(int id);

  // Check if category with name exists
  Future<bool> categoryExists(String name);

  // Get category count
  Future<int> getCategoryCount();
}
