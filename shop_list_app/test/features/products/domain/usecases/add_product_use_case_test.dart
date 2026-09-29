import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/products/domain/usecases/add_product_use_case.dart';

/// Hand-rolled fake implementing [IProductRepository]; every member throws
/// [UnimplementedError] unless the test overrides the relevant behavior,
/// mirroring the pantry feature's use case test convention.
class FakeProductRepository implements IProductRepository {
  FakeProductRepository({this.nextId = 3, this.addProductError});

  final int nextId;
  final Object? addProductError;
  Product? lastAdded;

  @override
  Future<int> addProduct(Product product) async {
    lastAdded = product;
    if (addProductError != null) throw addProductError!;
    return nextId;
  }

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
  Future<bool> deleteProduct(int id) async => throw UnimplementedError();

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
  group('AddProductUseCase', () {
    late FakeProductRepository repository;
    late AddProductUseCase useCase;

    setUp(() {
      repository = FakeProductRepository();
      useCase = AddProductUseCase(repository);
    });

    test('rejects an empty/blank name', () async {
      final result =
          await useCase.call(Product(name: '  ', productCategoryId: 1));

      expect(result.isLeft(), true);
      result.fold(
        (failure) =>
            expect(failure.message, contains('name must not be empty')),
        (_) => fail('Should have failed'),
      );
    });

    test('rejects a product with no category selected', () async {
      final result = await useCase.call(Product(name: 'Milk'));

      expect(result.isLeft(), true);
      result.fold(
        (failure) =>
            expect(failure.message, contains('category must be selected')),
        (_) => fail('Should have failed'),
      );
    });

    test('adds a valid product and returns its id', () async {
      final result =
          await useCase.call(Product(name: 'Milk', productCategoryId: 2));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have succeeded'),
        (id) => expect(id, 3),
      );
      expect(repository.lastAdded?.name, 'Milk');
    });

    test('returns Left(DatabaseFailure) when the repository throws', () async {
      repository =
          FakeProductRepository(addProductError: Exception('io error'));
      useCase = AddProductUseCase(repository);

      final result =
          await useCase.call(Product(name: 'Milk', productCategoryId: 2));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('io error')),
        (_) => fail('Should have failed'),
      );
    });
  });
}
