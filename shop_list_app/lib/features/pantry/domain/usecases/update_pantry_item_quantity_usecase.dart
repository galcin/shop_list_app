import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';

class UpdatePantryItemQuantityUseCase {
  final IPantryRepository _repository;

  UpdatePantryItemQuantityUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required int id,
    required double newQuantity,
  }) async {
    if (id <= 0) {
      return const Left(ValidationFailure('Invalid item id'));
    }

    // Clamp quantity to minimum 0
    final clampedQuantity = newQuantity < 0 ? 0 : newQuantity;

    try {
      final item = await _repository.getById(id);
      if (item == null) {
        return const Left(NotFoundFailure('Pantry item not found'));
      }

      final updatedItem = item.copyWith(quantity: clampedQuantity as double);
      final success = await _repository.update(updatedItem);

      return success
          ? const Right(true)
          : const Left(DatabaseFailure('Failed to update quantity'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
