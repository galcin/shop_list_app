import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';
import 'package:shop_list_app/domain/usecases/shopping/reorder_product_categories_use_case.dart';

class _FakeRepository implements IProductCategoryRepository {
  List<int>? lastReorderedIds;

  @override
  Future<Either<Failure, bool>> reorder(List<int> orderedIds) async {
    lastReorderedIds = orderedIds;
    return const Right(true);
  }

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
  Future<Either<Failure, bool>> delete(int id) async => const Right(true);

  @override
  Future<int> countProductsForCategory(int id) async => 0;

  @override
  Future<List<ProductCategory>> getAllCategories() async => [];

  @override
  Future<ProductCategory?> getCategoryById(int id) async => null;

  @override
  Future<int> addCategory(ProductCategory c) async => 0;

  @override
  Future<bool> updateCategory(ProductCategory c) async => true;

  @override
  Future<bool> deleteCategory(int id) async => true;
}

void main() {
  group('ReorderProductCategoriesUseCase', () {
    test('assigns sort indices in the given order', () async {
      final repo = _FakeRepository();
      final useCase = ReorderProductCategoriesUseCase(repo);

      final orderedIds = [3, 1, 4, 2];
      await useCase.call(orderedIds);

      // The use case passes the ids in the exact order provided to the repo;
      // the repo's bulkUpdateSortOrder assigns index i to orderedIds[i].
      expect(repo.lastReorderedIds, orderedIds);
    });

    test('returns Right(true) on success', () async {
      final repo = _FakeRepository();
      final useCase = ReorderProductCategoriesUseCase(repo);

      final result = await useCase.call([1, 2, 3]);
      expect(result.isRight(), isTrue);
    });

    test('returns Right(true) immediately for empty list', () async {
      final repo = _FakeRepository();
      final useCase = ReorderProductCategoriesUseCase(repo);

      final result = await useCase.call([]);
      expect(result.isRight(), isTrue);
      // Repository should not be called for empty list
      expect(repo.lastReorderedIds, isNull);
    });
  });
}
