import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';

/// Returns all [Product] records from the repository.
class GetAllProductsUseCase {
  GetAllProductsUseCase(this._repository);

  final IProductRepository _repository;

  Future<Either<Failure, List<Product>>> call() async {
    try {
      final products = await _repository.getAllProducts();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
