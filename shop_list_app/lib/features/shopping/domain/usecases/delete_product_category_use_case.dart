import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import '../repositories/i_product_category_repository.dart';

/// Deletes a [ProductCategory] by id.
///
/// Returns [ConflictFailure] if the category still has products assigned to it.
/// The caller should prompt the user before force-deleting.
class DeleteProductCategoryUseCase {
  DeleteProductCategoryUseCase(this._repository);

  final IProductCategoryRepository _repository;

  Future<Either<Failure, bool>> call(int id) {
    return _repository.delete(id);
  }

  /// Force-delete ignoring product assignments (used after user confirmation).
  Future<Either<Failure, bool>> forceDelete(int id) async {
    try {
      await _repository.deleteCategory(id);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
