import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';
import 'package:shop_list_app/domain/usecases/shopping/create_product_category_use_case.dart';

// Simple stub repository for use-case tests.
class _FakeRepository implements IProductCategoryRepository {
  final List<ProductCategory> _stored = [];
  int _nextId = 1;

  @override
  Stream<Either<Failure, List<ProductCategory>>> watchAll() =>
      Stream.value(Right(_stored));

  @override
  Future<Either<Failure, ProductCategory>> save(
      ProductCategory category) async {
    final saved = category.copyWith(id: _nextId++);
    _stored.add(saved);
    return Right(saved);
  }

  @override
  Future<Either<Failure, ProductCategory>> update(
          ProductCategory category) async =>
      Right(category);

  @override
  Future<Either<Failure, bool>> delete(int id) async => const Right(true);

  @override
  Future<Either<Failure, bool>> reorder(List<int> orderedIds) async =>
      const Right(true);

  @override
  Future<int> countProductsForCategory(int categoryId) async => 0;

  @override
  Future<List<ProductCategory>> getAllCategories() async => _stored;

  @override
  Future<ProductCategory?> getCategoryById(int id) async =>
      _stored.where((c) => c.id == id).firstOrNull;

  @override
  Future<int> addCategory(ProductCategory category) async {
    final result = await save(category);
    return result.fold((_) => 0, (c) => c.id);
  }

  @override
  Future<bool> updateCategory(ProductCategory category) async => true;

  @override
  Future<bool> deleteCategory(int id) async => true;
}

void main() {
  late CreateProductCategoryUseCase useCase;
  late _FakeRepository repository;

  setUp(() {
    repository = _FakeRepository();
    useCase = CreateProductCategoryUseCase(repository);
  });

  group('CreateProductCategoryUseCase', () {
    test('returns ValidationFailure when name is empty', () async {
      final result = await useCase.call(name: '');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, isNotEmpty);
        },
        (_) => fail('Expected a Left(ValidationFailure)'),
      );
    });

    test('returns ValidationFailure when name is only whitespace', () async {
      final result = await useCase.call(name: '   ');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected a Left(ValidationFailure)'),
      );
    });

    test('returns Right(ProductCategory) when name is valid', () async {
      final result = await useCase.call(name: 'Dairy');

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right but got Left($f)'),
        (category) {
          expect(category.name, 'Dairy');
          expect(category.id, greaterThan(0));
        },
      );
    });

    test('trims whitespace from name before saving', () async {
      final result = await useCase.call(name: '  Produce  ');

      result.fold(
        (f) => fail('Expected Right'),
        (category) => expect(category.name, 'Produce'),
      );
    });

    test('passes colorHex and iconName to repository', () async {
      final result = await useCase.call(
        name: 'Bakery',
        colorHex: '#FF6B35',
        iconName: '🍞',
      );

      result.fold(
        (f) => fail('Expected Right'),
        (category) {
          expect(category.colorHex, '#FF6B35');
          expect(category.iconName, '🍞');
        },
      );
    });
  });
}
