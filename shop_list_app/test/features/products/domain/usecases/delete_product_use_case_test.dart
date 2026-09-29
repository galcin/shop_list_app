import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/products/domain/usecases/delete_product_use_case.dart';

class FakeProductRepository implements IProductRepository {
  FakeProductRepository({this.deleteResult = true, this.deleteError});

  final bool deleteResult;
  final Object? deleteError;
  int? deletedId;

  @override
  Future<bool> deleteProduct(int id) async {
    deletedId = id;
    if (deleteError != null) throw deleteError!;
    return deleteResult;
  }

  @override
  Future<int> addProduct(Product product) async => throw UnimplementedError();

  @override
  Future<List<Product>> getAllProducts() async => throw UnimplementedError();

  @override
  Future<Product?> getProductById(int id) async => throw UnimplementedError();

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async =>
      throw UnimplementedError();

  @override
  Future<List<Product>> getExpiringProducts(int days) async =>
      throw UnimplementedError();

  @override
  Future<List<Product>> getExpiredProducts() async =>
      throw UnimplementedError();

  @override
  Future<List<Product>> searchProducts(String query) async =>
      throw UnimplementedError();

  @override
  Future<bool> updateProduct(Product product) async =>
      throw UnimplementedError();

  @override
  Future<int> deleteAllProducts() async => throw UnimplementedError();

  @override
  Future<int> getProductCount() async => throw UnimplementedError();

  @override
  Future<int> getProductCountByCategory(int categoryId) async =>
      throw UnimplementedError();

  @override
  Future<bool> productExists(String name) async => throw UnimplementedError();
}

void main() {
  group('DeleteProductUseCase', () {
    test('returns Right(true) and deletes the requested id', () async {
      final repository = FakeProductRepository();
      final useCase = DeleteProductUseCase(repository);

      final result = await useCase.call(11);

      expect(result.isRight(), true);
      result.fold((_) => fail('Should have succeeded'), (r) => expect(r, true));
      expect(repository.deletedId, 11);
    });

    test('returns Left(DatabaseFailure) when the repository throws', () async {
      final repository =
          FakeProductRepository(deleteError: Exception('locked'));
      final useCase = DeleteProductUseCase(repository);

      final result = await useCase.call(11);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('locked')),
        (_) => fail('Should have failed'),
      );
    });
  });
}
