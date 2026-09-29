import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Clears all meal slots for an entire week.
class ClearWeekUseCase {
  ClearWeekUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<Either<Failure, void>> call(int planId) async {
    try {
      await _repository.clearWeek(planId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
