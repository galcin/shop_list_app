import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Clears all meal slots for an entire week.
class ClearWeekUseCase {
  ClearWeekUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<void> call(int planId) async {
    await _repository.clearWeek(planId);
  }
}
