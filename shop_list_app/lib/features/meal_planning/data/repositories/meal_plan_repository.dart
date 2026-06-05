import 'package:shop_list_app/features/meal_planning/data/datasources/meal_plan_data_source.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';

/// Implementation of meal plan repository.
class MealPlanRepository implements IMealPlanRepository {
  MealPlanRepository(this._dataSource);

  final MealPlanDataSource _dataSource;

  @override
  Stream<MealPlan?> watchByWeek(DateTime weekStart) {
    return _dataSource.watchByWeek(weekStart);
  }

  @override
  Future<MealPlan> getOrCreateWeeklyPlan(DateTime weekStart) async {
    try {
      return await _dataSource.getOrCreateWeeklyPlan(weekStart);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> save(MealPlan plan) async {
    try {
      if (plan.id != null) {
        await _dataSource.updatePlan(plan.id!);
        return plan.id!;
      }
      // New plans should be created via getOrCreateWeeklyPlan
      throw UnsupportedError('Use getOrCreateWeeklyPlan to create new plans');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> assignRecipeToSlot({
    required int slotId,
    required int recipeId,
  }) async {
    try {
      await _dataSource.assignRecipeToSlot(
        slotId: slotId,
        recipeId: recipeId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearSlot(int slotId) async {
    try {
      await _dataSource.clearSlot(slotId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearDay({required int planId, required DateTime date}) async {
    try {
      await _dataSource.clearDay(planId: planId, date: date);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearWeek(int planId) async {
    try {
      await _dataSource.clearWeek(planId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> duplicatePlan({
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  }) async {
    try {
      await _dataSource.duplicatePlan(
        sourceWeekStart: sourceWeekStart,
        targetWeekStart: targetWeekStart,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<int>> getAssignedRecipeIds(int planId) async {
    try {
      return await _dataSource.getAssignedRecipeIds(planId);
    } catch (e) {
      rethrow;
    }
  }
}
