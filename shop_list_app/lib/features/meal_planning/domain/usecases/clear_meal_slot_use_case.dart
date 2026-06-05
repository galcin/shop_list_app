import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Clears a meal slot by removing its recipe assignment.
class ClearMealSlotUseCase {
  ClearMealSlotUseCase(this._repository);

  final IMealPlanRepository _repository;

  Future<void> call(int slotId) async {
    await _repository.clearSlot(slotId);
  }
}
