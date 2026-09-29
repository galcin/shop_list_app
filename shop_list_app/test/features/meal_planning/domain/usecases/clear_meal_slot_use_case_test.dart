import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/clear_meal_slot_use_case.dart';

/// Hand-rolled fake implementing [IMealPlanRepository]; every member throws
/// [UnimplementedError] unless the test overrides the relevant behavior,
/// mirroring the pantry feature's use case test convention.
class FakeMealPlanRepository implements IMealPlanRepository {
  FakeMealPlanRepository({this.clearSlotError});

  final Object? clearSlotError;
  int? clearedSlotId;

  @override
  Future<void> clearSlot(int slotId) async {
    clearedSlotId = slotId;
    if (clearSlotError != null) {
      throw clearSlotError!;
    }
  }

  @override
  Stream<MealPlan?> watchByWeek(DateTime weekStart) =>
      throw UnimplementedError();

  @override
  Future<MealPlan> getOrCreateWeeklyPlan(DateTime weekStart) async =>
      throw UnimplementedError();

  @override
  Future<int> save(MealPlan plan) async => throw UnimplementedError();

  @override
  Future<void> assignRecipeToSlot(
          {required int slotId, required int recipeId}) async =>
      throw UnimplementedError();

  @override
  Future<void> clearDay({required int planId, required DateTime date}) async =>
      throw UnimplementedError();

  @override
  Future<void> clearWeek(int planId) async => throw UnimplementedError();

  @override
  Future<void> duplicatePlan(
          {required DateTime sourceWeekStart,
          required DateTime targetWeekStart}) async =>
      throw UnimplementedError();

  @override
  Future<List<int>> getAssignedRecipeIds(int planId) async =>
      throw UnimplementedError();
}

void main() {
  group('ClearMealSlotUseCase', () {
    test('returns Right(null) and delegates to the repository on success',
        () async {
      final repository = FakeMealPlanRepository();
      final useCase = ClearMealSlotUseCase(repository);

      final result = await useCase.call(5);

      expect(result.isRight(), true);
      expect(repository.clearedSlotId, 5);
    });

    test('returns Left(DatabaseFailure) when the repository throws', () async {
      final repository =
          FakeMealPlanRepository(clearSlotError: Exception('db down'));
      final useCase = ClearMealSlotUseCase(repository);

      final result = await useCase.call(5);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('db down')),
        (_) => fail('Should have failed'),
      );
    });
  });
}
