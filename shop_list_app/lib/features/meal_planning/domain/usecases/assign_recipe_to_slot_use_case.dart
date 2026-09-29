import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Assigns a recipe to a specific meal slot.
class AssignRecipeToSlotUseCase {
  AssignRecipeToSlotUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<Either<Failure, void>> call({
    required int slotId,
    required int recipeId,
  }) async {
    try {
      await _repository.assignRecipeToSlot(
        slotId: slotId,
        recipeId: recipeId,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
