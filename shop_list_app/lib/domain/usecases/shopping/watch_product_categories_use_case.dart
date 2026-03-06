import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';

/// Exposes a reactive stream of all product categories.
///
/// Returns [Stream<Either<Failure, List<ProductCategory>>>] ordered by sortOrder.
class WatchProductCategoriesUseCase {
  WatchProductCategoriesUseCase(this._repository);

  final IProductCategoryRepository _repository;

  Stream<Either<Failure, List<ProductCategory>>> call() {
    return _repository.watchAll();
  }
}
