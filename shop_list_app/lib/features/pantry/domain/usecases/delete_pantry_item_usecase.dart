import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';

class DeletePantryItemUseCase {
  final IPantryRepository _repository;

  DeletePantryItemUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    if (id <= 0) {
      return const Left(ValidationFailure('Invalid item id'));
    }

    try {
      final success = await _repository.delete(id);
      return success
          ? const Right(true)
          : const Left(DatabaseFailure('Failed to delete item'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
