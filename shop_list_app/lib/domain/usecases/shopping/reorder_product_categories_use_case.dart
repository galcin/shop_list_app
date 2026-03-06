import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';

/// Bulk-updates the [sortOrder] of all categories.
///
/// [orderedIds] must contain the category ids in the desired new order.
/// Each id is assigned a sort index equal to its position in the list.
class ReorderProductCategoriesUseCase {
  ReorderProductCategoriesUseCase(this._repository);

  final IProductCategoryRepository _repository;

  Future<Either<Failure, bool>> call(List<int> orderedIds) {
    if (orderedIds.isEmpty) {
      return Future.value(const Right(true));
    }
    return _repository.reorder(orderedIds);
  }
}
