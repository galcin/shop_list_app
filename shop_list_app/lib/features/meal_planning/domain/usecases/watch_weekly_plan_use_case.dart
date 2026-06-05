import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Watches a meal plan for a given week (reactive stream).
class WatchWeeklyPlanUseCase {
  WatchWeeklyPlanUseCase(this._repository);

  final IMealPlanRepository _repository;

  Stream<MealPlan?> call(DateTime weekStart) {
    return _repository.watchByWeek(weekStart);
  }
}
