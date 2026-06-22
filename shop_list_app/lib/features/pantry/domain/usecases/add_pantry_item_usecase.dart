import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';

class AddPantryItemUseCase {
  final IPantryRepository _repository;

  AddPantryItemUseCase(this._repository);

  Future<Either<Failure, int>> call({
    required String name,
    required double quantity,
    required String unit,
    required int categoryId,
    int? productId,
    DateTime? expiryDate,
    String? location,
  }) async {
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Item name is required'));
    }

    if (quantity <= 0) {
      return const Left(ValidationFailure('Quantity must be greater than 0'));
    }

    if (unit.trim().isEmpty) {
      return const Left(ValidationFailure('Unit is required'));
    }

    try {
      final now = DateTime.now();
      final item = PantryItem(
        productId: productId,
        name: name.trim(),
        quantity: quantity,
        unit: unit.trim(),
        categoryId: categoryId,
        expiryDate: expiryDate,
        purchasedDate: now,
        location: location?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final id = await _repository.save(item);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
