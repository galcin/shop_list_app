import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping/domain/repositories/i_product_repository.dart';

/// Deletes a [Product] by [id].
class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);

  final IProductRepository _repository;

  Future<Either<Failure, bool>> call(int id) async {
    try {
      final success = await _repository.deleteProduct(id);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
