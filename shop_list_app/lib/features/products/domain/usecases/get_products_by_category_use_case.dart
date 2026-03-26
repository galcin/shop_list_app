import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';

/// Returns all [Product] records belonging to the given [categoryId].
class GetProductsByCategoryUseCase {
  GetProductsByCategoryUseCase(this._repository);

  final IProductRepository _repository;

  Future<Either<Failure, List<Product>>> call(int categoryId) async {
    try {
      final products = await _repository.getProductsByCategory(categoryId);
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
