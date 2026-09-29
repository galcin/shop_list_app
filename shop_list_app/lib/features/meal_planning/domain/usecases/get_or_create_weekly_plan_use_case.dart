import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Creates a meal plan for a given week if none exists, or returns the existing one.
class GetOrCreateWeeklyPlanUseCase {
  GetOrCreateWeeklyPlanUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<Either<Failure, MealPlan>> call(DateTime weekStart) async {
    try {
      final plan = await _repository.getOrCreateWeeklyPlan(weekStart);
      return Right(plan);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
