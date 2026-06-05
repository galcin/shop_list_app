import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Duplicates a meal plan from one week to another.
class DuplicateMealPlanUseCase {
  DuplicateMealPlanUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<void> call({
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  }) async {
    await _repository.duplicatePlan(
      sourceWeekStart: sourceWeekStart,
      targetWeekStart: targetWeekStart,
    );
  }
}
