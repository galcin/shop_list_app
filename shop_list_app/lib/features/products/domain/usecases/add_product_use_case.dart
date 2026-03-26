import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';

/// Validates and persists a new [Product].
///
/// Returns the new row [id] on success, or a [ValidationFailure] /
/// [DatabaseFailure] on failure.
class AddProductUseCase {
  AddProductUseCase(this._repository);

  final IProductRepository _repository;

  Future<Either<Failure, int>> call(Product product) async {
    final name = product.name?.trim() ?? '';
    if (name.isEmpty) {
      return const Left(ValidationFailure('Product name must not be empty.'));
    }
    if (product.productCategoryId == null) {
      return const Left(ValidationFailure('A category must be selected.'));
    }
    try {
      final id = await _repository.addProduct(product);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
