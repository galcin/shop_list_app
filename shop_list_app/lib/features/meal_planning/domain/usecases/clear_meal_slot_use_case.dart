import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Clears a meal slot by removing its recipe assignment.
class ClearMealSlotUseCase {
  ClearMealSlotUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<Either<Failure, void>> call(int slotId) async {
    try {
      await _repository.clearSlot(slotId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
