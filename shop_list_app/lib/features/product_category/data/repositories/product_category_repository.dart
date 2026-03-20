import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as model;
import 'package:shop_list_app/features/product_category/domain/repositories/i_product_category_repository.dart';
import 'package:shop_list_app/features/product_category/data/datasources/product_category_data_source.dart';

class ProductCategoryRepository implements IProductCategoryRepository {
  ProductCategoryRepository(this._dataSource);

  final ProductCategoryDataSource _dataSource;

  // -- Reactive (new) ----------------------------------------------------------

  @override
  Stream<Either<Failure, List<model.ProductCategory>>> watchAll() {
    return _dataSource
        .watchAll()
        .map<Either<Failure, List<model.ProductCategory>>>(
          (rows) => Right(rows.map(_toEntity).toList()),
        )
        .handleError(
      (e, StackTrace st) {
        AppLogger.instance.error(
          '[CategoryRepo] watchAll stream error',
          error: e,
          stackTrace: st,
        );
        return Left<Failure, List<model.ProductCategory>>(
            DatabaseFailure(e.toString()));
      },
    );
  }

  // -- Mutations (new Either-returning) ----------------------------------------

  @override
  Future<Either<Failure, model.ProductCategory>> save(
      model.ProductCategory category) async {
    try {
      final now = DateTime.now();
      final id = await _dataSource.insert(
        ProductCategoriesCompanion.insert(
          name: category.name,
          photo: Value(category.photo),
          colorHex: Value(category.colorHex),
          iconName: Value(category.iconName),
          imageName: Value(category.imageName),
          sortOrder: Value(category.sortOrder),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      final saved = category.copyWith(id: id, createdAt: now, updatedAt: now);
      return Right(saved);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, model.ProductCategory>> update(
      model.ProductCategory category) async {
    try {
      final now = DateTime.now();
      await _dataSource.updateById(
        category.id,
        ProductCategoriesCompanion(
          name: Value(category.name),
          photo: Value(category.photo),
          colorHex: Value(category.colorHex),
          iconName: Value(category.iconName),
          imageName: Value(category.imageName),
          sortOrder: Value(category.sortOrder),
          updatedAt: Value(now),
        ),
      );
      return Right(category.copyWith(updatedAt: now));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final count = await _dataSource.countProductsForCategory(id);
      if (count > 0) {
        return Left(ConflictFailure(
          'This category has $count product(s) assigned to it.',
        ));
      }
      final deleted = await _dataSource.deleteById(id);
      return Right(deleted > 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> reorder(List<int> orderedIds) async {
    try {
      await _dataSource.bulkUpdateSortOrder(orderedIds);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<int> countProductsForCategory(int categoryId) {
    return _dataSource.countProductsForCategory(categoryId);
  }

  // -- Legacy helpers -----------------------------------------------------------

  @override
  Future<List<model.ProductCategory>> getAllCategories() async {
    final rows = await _dataSource.getAll();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<model.ProductCategory?> getCategoryById(int id) async {
    final row = await _dataSource.getById(id);
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<int> addCategory(model.ProductCategory category) async {
    final result = await save(category);
    return result.fold((_) => 0, (saved) => saved.id);
  }

  @override
  Future<bool> updateCategory(model.ProductCategory category) async {
    final result = await update(category);
    return result.fold((_) => false, (_) => true);
  }

  @override
  Future<bool> deleteCategory(int id) async {
    // Legacy delete: bypasses conflict check by deleting directly.
    final deleted = await _dataSource.deleteById(id);
    return deleted > 0;
  }

  // -- Private helpers ----------------------------------------------------------

  model.ProductCategory _toEntity(ProductCategory row) {
    return model.ProductCategory(
      id: row.id,
      name: row.name,
      photo: row.photo,
      colorHex: row.colorHex,
      iconName: row.iconName,
      imageName: row.imageName,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
