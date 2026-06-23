import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/meal_planning/data/datasources/meal_plan_data_source.dart';
import 'package:shop_list_app/features/meal_planning/data/repositories/meal_plan_repository.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/assign_recipe_to_slot_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/clear_day_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/clear_meal_slot_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/clear_week_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/duplicate_meal_plan_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/generate_shopping_list_from_plan_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/get_or_create_weekly_plan_use_case.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/watch_weekly_plan_use_case.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final mealPlanDataSourceProvider = Provider<MealPlanDataSource>((ref) {
  return MealPlanDataSource(ref.watch(databaseProvider));
});

final mealPlanRepositoryProvider = Provider<IMealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(mealPlanDataSourceProvider));
});

// ── Use-case providers ────────────────────────────────────────────────────────

final getOrCreateWeeklyPlanUseCaseProvider =
    Provider<GetOrCreateWeeklyPlanUseCase>((ref) {
  return GetOrCreateWeeklyPlanUseCase(ref.watch(mealPlanRepositoryProvider));
});

final watchWeeklyPlanUseCaseProvider = Provider<WatchWeeklyPlanUseCase>((ref) {
  return WatchWeeklyPlanUseCase(ref.watch(mealPlanRepositoryProvider));
});

final assignRecipeToSlotUseCaseProvider =
    Provider<AssignRecipeToSlotUseCase>((ref) {
  return AssignRecipeToSlotUseCase(ref.watch(mealPlanRepositoryProvider));
});

final clearMealSlotUseCaseProvider = Provider<ClearMealSlotUseCase>((ref) {
  return ClearMealSlotUseCase(ref.watch(mealPlanRepositoryProvider));
});

final clearDayUseCaseProvider = Provider<ClearDayUseCase>((ref) {
  return ClearDayUseCase(ref.watch(mealPlanRepositoryProvider));
});

final clearWeekUseCaseProvider = Provider<ClearWeekUseCase>((ref) {
  return ClearWeekUseCase(ref.watch(mealPlanRepositoryProvider));
});

final duplicateMealPlanUseCaseProvider =
    Provider<DuplicateMealPlanUseCase>((ref) {
  return DuplicateMealPlanUseCase(ref.watch(mealPlanRepositoryProvider));
});

final generateShoppingListFromPlanUseCaseProvider =
    Provider<GenerateShoppingListFromPlanUseCase>((ref) {
  return GenerateShoppingListFromPlanUseCase(
    ref.watch(mealPlanRepositoryProvider),
    ref.watch(recipeRepositoryProvider),
    ref.watch(shoppingListRepositoryProvider),
  );
});

// ── Current week provider ─────────────────────────────────────────────────────

/// Provides the start of the current planning period (today).
/// This allows planning from the current day forward into the future.
final currentWeekStartProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ── Selected week state ───────────────────────────────────────────────────────

/// State notifier to track which week the user is viewing.
class SelectedWeekNotifier extends StateNotifier<DateTime> {
  SelectedWeekNotifier(super.initialWeek);

  void goToWeek(DateTime weekStart) {
    state = weekStart;
  }

  void goToPreviousWeek() {
    state = state.subtract(const Duration(days: 7));
  }

  void goToNextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void goToCurrentWeek(DateTime currentWeekStart) {
    state = currentWeekStart;
  }

  void goToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}

final selectedWeekProvider =
    StateNotifierProvider<SelectedWeekNotifier, DateTime>((ref) {
  final currentWeek = ref.watch(currentWeekStartProvider);
  return SelectedWeekNotifier(currentWeek);
});

// ── Helper function for getting week start (Monday) ──────────────────────────

/// Calculate the Monday of the week containing the given date.
DateTime _getWeekStart(DateTime date) {
  final weekday = date.weekday; // 1 = Monday, 7 = Sunday
  final daysToSubtract = weekday - 1;
  final weekStart = date.subtract(Duration(days: daysToSubtract));
  return DateTime(weekStart.year, weekStart.month, weekStart.day);
}

// ── Combined meal plan for 7-day view ─────────────────────────────────────────

/// A provider that combines slots from multiple weeks to provide
/// a unified 7-day view starting from the selected date.
final combinedSevenDayPlanProvider = StreamProvider<MealPlan?>((ref) async* {
  final selectedDate = ref.watch(selectedWeekProvider);

  // Calculate which weeks we need to load
  final currentWeekStart = _getWeekStart(selectedDate);
  final endDate = selectedDate.add(const Duration(days: 6));
  final nextWeekStart = _getWeekStart(endDate);
  final needsTwoWeeks = currentWeekStart != nextWeekStart;

  // Ensure both weeks exist
  await ref.read(getOrCreateWeeklyPlanUseCaseProvider).call(currentWeekStart);
  if (needsTwoWeeks) {
    await ref.read(getOrCreateWeeklyPlanUseCaseProvider).call(nextWeekStart);
  }

  // Watch current week
  await for (final currentPlan
      in ref.watch(watchWeeklyPlanUseCaseProvider).call(currentWeekStart)) {
    if (currentPlan == null) {
      yield null;
      continue;
    }

    if (!needsTwoWeeks) {
      // All 7 days are in the same week
      yield currentPlan;
    } else {
      // Need to combine data from both weeks
      // Get next week's plan synchronously
      final nextPlan = await ref
          .read(getOrCreateWeeklyPlanUseCaseProvider)
          .call(nextWeekStart);

      // Combine slots from both weeks
      final combinedSlots = <MealSlot>[
        ...currentPlan.slots,
        ...nextPlan.slots,
      ];

      // Create a unified plan with slots from both weeks
      yield currentPlan.copyWith(slots: combinedSlots);
    }
  }
});

// ── Weekly meal plan notifier ─────────────────────────────────────────────────

/// Streams the meal plan for the currently selected week.
final weeklyMealPlanProvider =
    StreamNotifierProvider<WeeklyMealPlanNotifier, MealPlan?>(
  WeeklyMealPlanNotifier.new,
);

class WeeklyMealPlanNotifier extends StreamNotifier<MealPlan?> {
  @override
  Stream<MealPlan?> build() async* {
    final selectedDate = ref.watch(selectedWeekProvider);

    // Calculate the Monday of the week containing selectedDate
    final currentWeekStart = _getWeekStart(selectedDate);

    // Also check if the 7-day view crosses into next week
    final endDate = selectedDate.add(const Duration(days: 6));
    final nextWeekStart = _getWeekStart(endDate);

    // Ensure plan exists for the current week
    await ref.read(getOrCreateWeeklyPlanUseCaseProvider).call(currentWeekStart);

    // If the 7-day view crosses into next week, ensure that week exists too
    if (currentWeekStart != nextWeekStart) {
      await ref.read(getOrCreateWeeklyPlanUseCaseProvider).call(nextWeekStart);
    }

    // Watch the current week's plan
    yield* ref.watch(watchWeeklyPlanUseCaseProvider).call(currentWeekStart);
  }

  Future<void> assignRecipe({
    required int slotId,
    required int recipeId,
  }) async {
    await ref.read(assignRecipeToSlotUseCaseProvider).call(
          slotId: slotId,
          recipeId: recipeId,
        );
  }

  Future<void> clearSlot(int slotId) async {
    await ref.read(clearMealSlotUseCaseProvider).call(slotId);
  }

  Future<void> clearDay({
    required int planId,
    required DateTime date,
  }) async {
    await ref.read(clearDayUseCaseProvider).call(
          planId: planId,
          date: date,
        );
  }

  Future<void> clearWeek(int planId) async {
    await ref.read(clearWeekUseCaseProvider).call(planId);
  }

  Future<void> duplicatePreviousWeek() async {
    final currentWeek = ref.read(selectedWeekProvider);
    final previousWeek = currentWeek.subtract(const Duration(days: 7));

    await ref.read(duplicateMealPlanUseCaseProvider).call(
          sourceWeekStart: previousWeek,
          targetWeekStart: currentWeek,
        );
  }

  /// Generate a shopping list from the current meal plan.
  Future<int> generateShoppingList({
    required int planId,
    required String listName,
  }) async {
    return await ref.read(generateShoppingListFromPlanUseCaseProvider).call(
          planId: planId,
          listName: listName,
        );
  }
}
