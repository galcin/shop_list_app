import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import 'package:shop_list_app/features/shopping/domain/repositories/i_product_repository.dart';

/// Validates and updates an existing [Product].
class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);

  final IProductRepository _repository;

  Future<Either<Failure, bool>> call(Product product) async {
    if (product.id == null) {
      return const Left(ValidationFailure('Product id must not be null.'));
    }
    final name = product.name?.trim() ?? '';
    if (name.isEmpty) {
      return const Left(ValidationFailure('Product name must not be empty.'));
    }
    try {
      final success = await _repository.updateProduct(product);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
