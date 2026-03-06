import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';
import 'package:shop_list_app/domain/usecases/shopping/delete_product_category_use_case.dart';

// Stub that tracks product count per category.
class _FakeRepository implements IProductCategoryRepository {
  final Map<int, int> _productCounts;

  _FakeRepository({Map<int, int>? productCounts})
      : _productCounts = productCounts ?? {};

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    final count = _productCounts[id] ?? 0;
    if (count > 0) {
      return Left(ConflictFailure(
        'This category has $count product(s) assigned to it.',
      ));
    }
    return const Right(true);
  }

  @override
  Future<bool> deleteCategory(int id) async => true;

  @override
  Stream<Either<Failure, List<ProductCategory>>> watchAll() =>
      Stream.value(const Right([]));

  @override
  Future<Either<Failure, ProductCategory>> save(ProductCategory c) async =>
      Right(c);

  @override
  Future<Either<Failure, ProductCategory>> update(ProductCategory c) async =>
      Right(c);

  @override
  Future<Either<Failure, bool>> reorder(List<int> ids) async =>
      const Right(true);

  @override
  Future<int> countProductsForCategory(int id) async => _productCounts[id] ?? 0;

  @override
  Future<List<ProductCategory>> getAllCategories() async => [];

  @override
  Future<ProductCategory?> getCategoryById(int id) async => null;

  @override
  Future<int> addCategory(ProductCategory c) async => 0;

  @override
  Future<bool> updateCategory(ProductCategory c) async => true;
}

void main() {
  group('DeleteProductCategoryUseCase', () {
    test('returns Right(true) when category has no products', () async {
      final repo = _FakeRepository();
      final useCase = DeleteProductCategoryUseCase(repo);

      final result = await useCase.call(42);

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right but got Left($f)'),
        (ok) => expect(ok, isTrue),
      );
    });

    test('returns ConflictFailure when category still has products', () async {
      final repo = _FakeRepository(productCounts: {42: 3});
      final useCase = DeleteProductCategoryUseCase(repo);

      final result = await useCase.call(42);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ConflictFailure>());
          expect(failure.message, contains('3'));
        },
        (_) => fail('Expected ConflictFailure'),
      );
    });

    test('forceDelete succeeds even when category has products', () async {
      final repo = _FakeRepository(productCounts: {42: 3});
      final useCase = DeleteProductCategoryUseCase(repo);

      final result = await useCase.forceDelete(42);

      expect(result.isRight(), isTrue);
    });
  });
}
