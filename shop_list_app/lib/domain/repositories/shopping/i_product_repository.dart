import 'package:shop_list_app/domain/entities/shopping/product.dart';

abstract class IProductRepository {
  // Get all products
  Future<List<Product>> getAllProducts();

  // Get product by ID
  Future<Product?> getProductById(int id);

  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId);

  // Get expiring products (within specified days)
  Future<List<Product>> getExpiringProducts(int days);

  // Get expired products
  Future<List<Product>> getExpiredProducts();

  // Search products by name
  Future<List<Product>> searchProducts(String query);

  // Add a new product
  Future<int> addProduct(Product product);

  // Update an existing product
  Future<bool> updateProduct(Product product);

  // Delete a product
  Future<bool> deleteProduct(int id);

  // Delete all products
  Future<int> deleteAllProducts();

  // Get product count
  Future<int> getProductCount();

  // Get product count by category
  Future<int> getProductCountByCategory(int categoryId);

  // Check if product with name exists
  Future<bool> productExists(String name);
}
