import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_type.dart';

void main() {
  group('MealSlot', () {
    final baseDate = DateTime(2026, 1, 5);

    test('isEmpty is true when there is no recipe and no custom name', () {
      final slot = MealSlot(
        planId: 1,
        date: baseDate,
        mealType: MealType.breakfast,
      );

      expect(slot.isEmpty, true);
    });

    test('isEmpty is false when a recipe is assigned', () {
      final slot = MealSlot(
        planId: 1,
        date: baseDate,
        mealType: MealType.breakfast,
        recipeId: 42,
        recipeName: 'Pancakes',
      );

      expect(slot.isEmpty, false);
    });

    test('isEmpty is false when a custom (non-blank) name is set', () {
      final slot = MealSlot(
        planId: 1,
        date: baseDate,
        mealType: MealType.lunch,
        customName: 'Leftovers',
      );

      expect(slot.isEmpty, false);
    });

    test('displayName prefers the recipe name over the custom name', () {
      final slot = MealSlot(
        planId: 1,
        date: baseDate,
        mealType: MealType.dinner,
        recipeName: 'Pasta',
        customName: 'Leftovers',
      );

      expect(slot.displayName, 'Pasta');
    });

    test('clear() removes the recipe assignment but keeps slot identity', () {
      final slot = MealSlot(
        id: 9,
        planId: 1,
        date: baseDate,
        mealType: MealType.dinner,
        recipeId: 42,
        recipeName: 'Pasta',
      );

      final cleared = slot.clear();

      expect(cleared.id, 9);
      expect(cleared.planId, 1);
      expect(cleared.mealType, MealType.dinner);
      expect(cleared.recipeId, isNull);
      expect(cleared.recipeName, isNull);
      expect(cleared.isEmpty, true);
    });
  });
}
