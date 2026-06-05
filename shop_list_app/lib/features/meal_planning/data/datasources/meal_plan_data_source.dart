import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart' as db;
import 'package:shop_list_app/core/database/tables/meal_slot_table.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart'
    as domain;
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart'
    as entity;

/// Drift-backed data source for meal planning operations.
class MealPlanDataSource {
  MealPlanDataSource(this._db);

  final db.AppDatabase _db;

  // ── Plans ──────────────────────────────────────────────────────────────────

  /// Stream of the meal plan for a given week.
  Stream<domain.MealPlan?> watchByWeek(DateTime weekStart) {
    final normalizedStart = _normalizeToWeekStart(weekStart);

    final planStream = (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(normalizedStart)))
        .watchSingleOrNull();

    return planStream.asyncMap((planRow) async {
      if (planRow == null) return null;
      final slots = await _slotsForPlan(planRow.id);
      return _planFromRow(planRow, slots);
    });
  }

  /// Get or create a meal plan for a specific week.
  Future<domain.MealPlan> getOrCreateWeeklyPlan(DateTime weekStart) async {
    final normalizedStart = _normalizeToWeekStart(weekStart);

    // Check if plan already exists
    final existing = await (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(normalizedStart)))
        .getSingleOrNull();

    if (existing != null) {
      final slots = await _slotsForPlan(existing.id);
      return _planFromRow(existing, slots);
    }

    // Create new plan with empty slots
    return _db.transaction(() async {
      final planId = await _db.into(_db.mealPlans).insert(
            db.MealPlansCompanion.insert(
              weekStartDate: normalizedStart,
            ),
          );

      // Create 21 empty slots (7 days × 3 meal types)
      final slots = <entity.MealSlot>[];
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = normalizedStart.add(Duration(days: dayOffset));
        for (final mealType in MealType.values) {
          final slotId = await _db.into(_db.mealSlots).insert(
                db.MealSlotsCompanion.insert(
                  planId: planId,
                  date: date,
                  mealType: mealType,
                ),
              );
          slots.add(entity.MealSlot(
            id: slotId,
            planId: planId,
            date: date,
            mealType: mealType,
          ));
        }
      }

      return domain.MealPlan(
        id: planId,
        weekStartDate: normalizedStart,
        slots: slots,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  /// Save a meal plan (update only, since creation is handled by getOrCreateWeeklyPlan).
  Future<void> updatePlan(int planId) async {
    await (_db.update(_db.mealPlans)..where((t) => t.id.equals(planId)))
        .write(db.MealPlansCompanion(
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ── Slots ──────────────────────────────────────────────────────────────────

  /// Assign a recipe to a specific meal slot.
  Future<void> assignRecipeToSlot({
    required int slotId,
    required int recipeId,
  }) async {
    await (_db.update(_db.mealSlots)..where((t) => t.id.equals(slotId)))
        .write(db.MealSlotsCompanion(
      recipeId: Value(recipeId),
      customName: const Value(null),
      updatedAt: Value(DateTime.now()),
    ));

    // Update plan's updatedAt
    final slot = await (_db.select(_db.mealSlots)
          ..where((t) => t.id.equals(slotId)))
        .getSingle();
    await updatePlan(slot.planId);
  }

  /// Clear a meal slot (remove recipe assignment).
  Future<void> clearSlot(int slotId) async {
    await (_db.update(_db.mealSlots)..where((t) => t.id.equals(slotId)))
        .write(const db.MealSlotsCompanion(
      recipeId: Value(null),
      customName: Value(null),
      updatedAt: Value.absent(),
    ));

    // Update plan's updatedAt
    final slot = await (_db.select(_db.mealSlots)
          ..where((t) => t.id.equals(slotId)))
        .getSingle();
    await updatePlan(slot.planId);
  }

  /// Clear all slots for a specific date.
  Future<void> clearDay({required int planId, required DateTime date}) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await (_db.update(_db.mealSlots)
          ..where(
              (t) => t.planId.equals(planId) & t.date.equals(normalizedDate)))
        .write(const db.MealSlotsCompanion(
      recipeId: Value(null),
      customName: Value(null),
      updatedAt: Value.absent(),
    ));
    await updatePlan(planId);
  }

  /// Clear all slots for a week.
  Future<void> clearWeek(int planId) async {
    await (_db.update(_db.mealSlots)..where((t) => t.planId.equals(planId)))
        .write(const db.MealSlotsCompanion(
      recipeId: Value(null),
      customName: Value(null),
      updatedAt: Value.absent(),
    ));
    await updatePlan(planId);
  }

  /// Duplicate a meal plan from one week to another.
  Future<void> duplicatePlan({
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  }) async {
    final normalizedSource = _normalizeToWeekStart(sourceWeekStart);
    final normalizedTarget = _normalizeToWeekStart(targetWeekStart);

    // Get source plan
    final sourcePlan = await (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(normalizedSource)))
        .getSingleOrNull();

    if (sourcePlan == null) return;

    // Get or create target plan
    final targetPlan = await getOrCreateWeeklyPlan(normalizedTarget);

    // Get source slots
    final sourceSlots = await (_db.select(_db.mealSlots)
          ..where((t) => t.planId.equals(sourcePlan.id)))
        .get();

    // Copy assignments to target slots
    await _db.transaction(() async {
      for (final sourceSlot in sourceSlots) {
        // Calculate day offset from week start
        final dayOffset = sourceSlot.date.difference(normalizedSource).inDays;
        final targetDate = normalizedTarget.add(Duration(days: dayOffset));

        // Find matching target slot
        final targetSlot = await (_db.select(_db.mealSlots)
              ..where((t) =>
                  t.planId.equals(targetPlan.id!) &
                  t.date.equals(targetDate) &
                  t.mealType.equals(sourceSlot.mealType.index)))
            .getSingleOrNull();

        if (targetSlot != null && sourceSlot.recipeId != null) {
          await (_db.update(_db.mealSlots)
                ..where((t) => t.id.equals(targetSlot.id)))
              .write(db.MealSlotsCompanion(
            recipeId: Value(sourceSlot.recipeId),
            customName: Value(sourceSlot.customName),
            updatedAt: Value(DateTime.now()),
          ));
        }
      }
    });

    await updatePlan(targetPlan.id!);
  }

  /// Get all recipe IDs assigned in a given plan.
  Future<List<int>> getAssignedRecipeIds(int planId) async {
    final slots = await (_db.select(_db.mealSlots)
          ..where((t) => t.planId.equals(planId) & t.recipeId.isNotNull()))
        .get();
    return slots.map((s) => s.recipeId!).toList();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<List<entity.MealSlot>> _slotsForPlan(int planId) async {
    final slots = await (_db.select(_db.mealSlots)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();

    // Fetch recipe details for denormalization
    final slotEntities = <entity.MealSlot>[];
    for (final slot in slots) {
      String? recipeName;
      String? recipeImageUrl;

      if (slot.recipeId != null) {
        final recipe = await (_db.select(_db.recipes)
              ..where((t) => t.id.equals(slot.recipeId!)))
            .getSingleOrNull();
        recipeName = recipe?.name;
        recipeImageUrl = recipe?.imageUrl;
      }

      slotEntities.add(entity.MealSlot(
        id: slot.id,
        planId: slot.planId,
        date: slot.date,
        mealType: slot.mealType,
        recipeId: slot.recipeId,
        recipeName: recipeName,
        recipeImageUrl: recipeImageUrl,
        customName: slot.customName,
        createdAt: slot.createdAt,
        updatedAt: slot.updatedAt,
      ));
    }

    return slotEntities;
  }

  domain.MealPlan _planFromRow(
      db.MealPlan planRow, List<entity.MealSlot> slots) {
    return domain.MealPlan(
      id: planRow.id,
      weekStartDate: planRow.weekStartDate,
      slots: slots,
      createdAt: planRow.createdAt,
      updatedAt: planRow.updatedAt,
    );
  }

  /// Normalize a date to the start of its week (Monday).
  DateTime _normalizeToWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysToSubtract = weekday - 1;
    final weekStart = date.subtract(Duration(days: daysToSubtract));
    return DateTime(weekStart.year, weekStart.month, weekStart.day);
  }
}
