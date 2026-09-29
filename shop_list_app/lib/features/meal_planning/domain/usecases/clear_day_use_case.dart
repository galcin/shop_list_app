import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Clears all meal slots for a specific day.
class ClearDayUseCase {
  ClearDayUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<Either<Failure, void>> call({
    required int planId,
    required DateTime date,
  }) async {
    try {
      await _repository.clearDay(planId: planId, date: date);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
