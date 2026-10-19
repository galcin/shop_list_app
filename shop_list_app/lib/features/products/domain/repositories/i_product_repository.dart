import 'package:shop_list_app/features/products/domain/entities/product.dart';

abstract class IProductRepository {
  /// All catalogue products ordered by name.
  Future<List<Product>> getAllProducts();

  Future<Product?> getProductById(int id);

  /// Fetch several products in one query.
  Future<List<Product>> getProductsByIds(List<int> ids);

  Future<List<Product>> getProductsByCategory(int categoryId);

  /// Case-insensitive name search.
  Future<List<Product>> searchProducts(String query);

  /// Exact match on name or alias (case-insensitive, plural tolerant).
  Future<Product?> findByNameOrAlias(String name);

  Future<int> addProduct(Product product);
  Future<bool> updateProduct(Product product);
  Future<bool> deleteProduct(int id);
  Future<int> deleteAllProducts();
  Future<int> getProductCount();
  Future<int> getProductCountByCategory(int categoryId);
  Future<bool> productExists(String name);
}
