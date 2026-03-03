import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import '../entities/product_category.dart';
import '../repositories/i_product_category_repository.dart';

/// Updates an existing [ProductCategory] by id.
///
/// Validates that [name] is non-empty and delegates to [IProductCategoryRepository.update].
class UpdateProductCategoryUseCase {
  UpdateProductCategoryUseCase(this._repository);

  final IProductCategoryRepository _repository;

  Future<Either<Failure, ProductCategory>> call({
    required int id,
    required String name,
    String? colorHex,
    String? iconName,
    int? sortOrder,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(ValidationFailure('Category name must not be empty.'));
    }

    final category = ProductCategory(
      id: id,
      name: trimmedName,
      colorHex: colorHex,
      iconName: iconName,
      sortOrder: sortOrder ?? 0,
    );

    return _repository.update(category);
  }
}
