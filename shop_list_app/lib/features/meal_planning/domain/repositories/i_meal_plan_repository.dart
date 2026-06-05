import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';

/// Repository interface for meal planning operations.
abstract class IMealPlanRepository {
  /// Stream of the meal plan for a given week.
  /// Returns null if no plan exists for that week.
  Stream<MealPlan?> watchByWeek(DateTime weekStart);

  /// Get or create a meal plan for a specific week.
  /// If a plan already exists, returns it; otherwise creates a new one with empty slots.
  Future<MealPlan> getOrCreateWeeklyPlan(DateTime weekStart);

  /// Save a meal plan (insert or update).
  Future<int> save(MealPlan plan);

  /// Assign a recipe to a specific meal slot.
  Future<void> assignRecipeToSlot({
    required int slotId,
    required int recipeId,
  });

  /// Clear a meal slot (remove recipe assignment).
  Future<void> clearSlot(int slotId);

  /// Clear all slots for a specific date.
  Future<void> clearDay({required int planId, required DateTime date});

  /// Clear all slots for a week.
  Future<void> clearWeek(int planId);

  /// Duplicate a meal plan from one week to another.
  Future<void> duplicatePlan({
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  });

  /// Get all recipe IDs assigned in a given week.
  Future<List<int>> getAssignedRecipeIds(int planId);
}
