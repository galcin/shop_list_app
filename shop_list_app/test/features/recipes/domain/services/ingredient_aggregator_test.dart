import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/services/ingredient_aggregator.dart';

void main() {
  const aggregator = IngredientAggregator();

  test('sums quantities of the same product in the same unit', () {
    const a = Recipe(id: 1, name: 'A', servings: 2, ingredients: [
      Ingredient(productId: 10, name: 'Flour', quantity: 200, unit: 'g'),
    ]);
    const b = Recipe(id: 2, name: 'B', servings: 2, ingredients: [
      Ingredient(productId: 10, name: 'Wheat flour', quantity: 300, unit: 'g'),
    ]);

    final result = aggregator.aggregate([a, b]);

    expect(result, hasLength(1));
    expect(result.single.productId, 10);
    expect(result.single.quantity, 500);
    expect(result.single.name, 'Flour', reason: 'first name wins');
  });

  test('keeps different units apart and falls back to names', () {
    const a = Recipe(id: 1, ingredients: [
      Ingredient(productId: 10, name: 'Flour', quantity: 200, unit: 'g'),
      Ingredient(name: 'Secret spice', quantity: 1, unit: 'tsp'),
    ]);
    const b = Recipe(id: 2, ingredients: [
      Ingredient(productId: 10, name: 'Flour', quantity: 1, unit: 'cup'),
      Ingredient(name: 'secret   SPICE', quantity: 2, unit: 'tsp'),
    ]);

    final result = aggregator.aggregate([a, b]);

    expect(result, hasLength(3));
    final spice = result.firstWhere((r) => r.productId == null);
    expect(spice.quantity, 3);
  });

  test('unmeasured ingredients merge without inventing quantities', () {
    const a = Recipe(id: 1, ingredients: [
      Ingredient(productId: 5, name: 'Salt', note: 'to taste'),
    ]);
    const b = Recipe(id: 2, ingredients: [
      Ingredient(productId: 5, name: 'Salt', note: 'pinch'),
    ]);
    const c = Recipe(id: 3, ingredients: [
      Ingredient(productId: 5, name: 'Salt', quantity: 1, unit: ''),
    ]);

    expect(aggregator.aggregate([a, b]).single.quantity, isNull);
    expect(aggregator.aggregate([a, c]).single.quantity, 1);
  });

  test('scales recipes to the requested servings before merging', () {
    const recipe = Recipe(id: 1, servings: 2, ingredients: [
      Ingredient(productId: 1, name: 'Eggs', quantity: 2, unit: 'pcs'),
    ]);

    final result =
        aggregator.aggregate([recipe], servingsOverride: {1: 6}).single;

    expect(result.quantity, 6);
  });
}
