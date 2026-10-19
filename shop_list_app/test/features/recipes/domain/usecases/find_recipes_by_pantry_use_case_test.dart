import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/find_recipes_by_pantry_use_case.dart';

class _StubRecipeRepository implements IRecipeRepository {
  _StubRecipeRepository(this.recipes);
  final List<Recipe> recipes;

  @override
  Future<List<Recipe>> getAllRecipes() async => recipes;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

PantryItem _pantry(String name, {int? productId, double quantity = 1}) {
  final now = DateTime(2026, 1, 1);
  return PantryItem(
    name: name,
    productId: productId,
    quantity: quantity,
    unit: 'pcs',
    categoryId: 1,
    purchasedDate: now,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const omelet = Recipe(id: 1, name: 'Omelet', ingredients: [
    Ingredient(productId: 100, name: 'Eggs', quantity: 2, unit: 'pcs'),
    Ingredient(productId: 101, name: 'Butter', quantity: 1, unit: 'tbsp'),
    Ingredient(productId: 102, name: 'Salt', note: 'to taste'),
  ]);
  const salad = Recipe(id: 2, name: 'Salad', ingredients: [
    Ingredient(name: 'Cherry tomatoes', quantity: 200, unit: 'g'),
    Ingredient(name: 'Cucumber', quantity: 1, unit: 'pcs'),
    Ingredient(name: 'Feta', quantity: 100, unit: 'g'),
  ]);

  final useCase =
      FindRecipesByPantryUseCase(_StubRecipeRepository([omelet, salad]));

  test('matches by product id first and ignores unmeasured staples', () async {
    final results = await useCase.call([
      _pantry('Large eggs', productId: 100),
      _pantry('Unt', productId: 101),
    ]);

    expect(results, hasLength(1));
    expect(results.single.recipe.id, 1);
    expect(results.single.percentageAvailable, 100);
    expect(results.single.missingIngredients, isEmpty,
        reason: 'salt (to taste) is not counted');
  });

  test('falls back to name containment for free-text ingredients', () async {
    final results = await useCase.call([
      _pantry('Tomatoes'),
      _pantry('cucumber'),
    ]);

    expect(results, hasLength(1));
    final match = results.single;
    expect(match.recipe.id, 2);
    expect(match.availableIngredients.map((i) => i.name),
        ['Cherry tomatoes', 'Cucumber']);
    expect(match.missingIngredients.single.name, 'Feta');
  });

  test('sorts the most complete recipes first', () async {
    final results = await useCase.call([
      _pantry('Eggs', productId: 100),
      _pantry('Feta'),
    ]);

    expect(results.map((r) => r.recipe.id), [1, 2]);
  });

  test('out-of-stock pantry items do not count', () async {
    final results = await useCase.call([
      _pantry('Eggs', productId: 100, quantity: 0),
    ]);

    expect(results, isEmpty);
  });
}
