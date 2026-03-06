import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';

/// Creates a new [ProductCategory].
///
/// Validates that [name] is non-empty and delegates to [IProductCategoryRepository.save].
class CreateProductCategoryUseCase {
  CreateProductCategoryUseCase(this._repository);

  final IProductCategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call({
    required String name,
    String? colorHex,
    String? iconName,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(ValidationFailure('Category name must not be empty.'));
    }

    final category = ProductCategory(
      id: 0, // assigned by the database (autoIncrement)
      name: trimmedName,
      colorHex: colorHex,
      iconName: iconName,
    );

    return _repository.save(category);
  }
}
