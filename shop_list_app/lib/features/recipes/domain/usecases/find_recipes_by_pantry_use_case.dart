import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Result of matching a recipe against available pantry items.
class RecipeMatchResult {
  final Recipe recipe;

  /// Ingredients from the recipe that are available in pantry (by name match).
  final List<Ingredient> availableIngredients;

  /// Ingredients from the recipe that are NOT available in pantry.
  final List<Ingredient> missingIngredients;

  /// Percentage of ingredients available (0-100).
  final double percentageAvailable;

  RecipeMatchResult({
    required this.recipe,
    required this.availableIngredients,
    required this.missingIngredients,
  }) : percentageAvailable = _calculatePercentage(
          availableIngredients.length,
          availableIngredients.length + missingIngredients.length,
        );

  static double _calculatePercentage(int available, int total) {
    if (total == 0) return 0;
    return (available / total) * 100;
  }
}

/// Use case to find recipes that can be made with available pantry items.
class FindRecipesByPantryUseCase {
  final IRecipeRepository _recipeRepository;

  FindRecipesByPantryUseCase(this._recipeRepository);

  /// Returns recipes sorted by ingredient availability (most complete first).
  Future<List<RecipeMatchResult>> call(List<PantryItem> pantryItems) async {
    final recipes = await _recipeRepository.getAllRecipes();

    if (recipes.isEmpty || pantryItems.isEmpty) {
      return [];
    }

    // Normalize pantry item names for matching
    final pantryItemNames =
        pantryItems.map((item) => _normalizeName(item.name)).toSet();

    final results = <RecipeMatchResult>[];

    for (final recipe in recipes) {
      if (recipe.ingredients?.isEmpty ?? true) continue;

      final available = <Ingredient>[];
      final missing = <Ingredient>[];

      for (final ingredient in recipe.ingredients!) {
        if (_ingredientAvailable(ingredient, pantryItemNames)) {
          available.add(ingredient);
        } else {
          missing.add(ingredient);
        }
      }

      results.add(
        RecipeMatchResult(
          recipe: recipe,
          availableIngredients: available,
          missingIngredients: missing,
        ),
      );
    }

    results.removeWhere((result) => result.availableIngredients.isEmpty);

    // Sort by percentage available (desc), then by recipe name
    results.sort((a, b) {
      final percentCompare =
          b.percentageAvailable.compareTo(a.percentageAvailable);
      if (percentCompare != 0) return percentCompare;
      return (a.recipe.name ?? '').compareTo(b.recipe.name ?? '');
    });

    return results;
  }

  bool _ingredientAvailable(
    Ingredient ingredient,
    Set<String> pantryItemNames,
  ) {
    final normalizedIngreName = _normalizeName(ingredient.name);

    for (final pantryName in pantryItemNames) {
      if (pantryName == normalizedIngreName ||
          pantryName.contains(normalizedIngreName) ||
          normalizedIngreName.contains(pantryName)) {
        return true;
      }
    }

    return false;
  }

  String _normalizeName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
