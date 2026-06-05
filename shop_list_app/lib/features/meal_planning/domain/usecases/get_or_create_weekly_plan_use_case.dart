import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Creates a meal plan for a given week if none exists, or returns the existing one.
class GetOrCreateWeeklyPlanUseCase {
  GetOrCreateWeeklyPlanUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<MealPlan> call(DateTime weekStart) async {
    return await _repository.getOrCreateWeeklyPlan(weekStart);
  }
}
