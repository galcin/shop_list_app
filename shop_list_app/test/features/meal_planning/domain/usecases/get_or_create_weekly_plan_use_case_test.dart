import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_plan.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';
import 'package:shop_list_app/features/meal_planning/domain/usecases/get_or_create_weekly_plan_use_case.dart';

class FakeMealPlanRepository implements IMealPlanRepository {
  FakeMealPlanRepository({this.planToReturn, this.error});

  final MealPlan? planToReturn;
  final Object? error;
  DateTime? requestedWeekStart;

  @override
  Future<MealPlan> getOrCreateWeeklyPlan(DateTime weekStart) async {
    requestedWeekStart = weekStart;
    if (error != null) throw error!;
    return planToReturn ?? MealPlan(weekStartDate: weekStart);
  }

  @override
  Stream<MealPlan?> watchByWeek(DateTime weekStart) =>
      throw UnimplementedError();

  @override
  Future<int> save(MealPlan plan) async => throw UnimplementedError();

  @override
  Future<void> assignRecipeToSlot(
          {required int slotId, required int recipeId}) async =>
      throw UnimplementedError();

  @override
  Future<void> clearSlot(int slotId) async => throw UnimplementedError();

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
  group('GetOrCreateWeeklyPlanUseCase', () {
    test('returns Right(plan) for the requested week on success', () async {
      final weekStart = DateTime(2026, 1, 5);
      final repository = FakeMealPlanRepository(
        planToReturn: MealPlan(weekStartDate: weekStart),
      );
      final useCase = GetOrCreateWeeklyPlanUseCase(repository);

      final result = await useCase.call(weekStart);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have succeeded'),
        (plan) => expect(plan.weekStartDate, weekStart),
      );
      expect(repository.requestedWeekStart, weekStart);
    });

    test('returns Left(DatabaseFailure) when the repository throws', () async {
      final repository =
          FakeMealPlanRepository(error: Exception('no connection'));
      final useCase = GetOrCreateWeeklyPlanUseCase(repository);

      final result = await useCase.call(DateTime(2026, 1, 5));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('no connection')),
        (_) => fail('Should have failed'),
      );
    });
  });
}
