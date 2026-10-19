import 'package:shop_list_app/core/database/seeder/seed_data.dart'
    show normalizeSeedName;
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Result of matching a recipe against available pantry items.
class RecipeMatchResult {
  final Recipe recipe;

  /// Ingredients from the recipe that are available in the pantry.
  final List<Ingredient> availableIngredients;

  /// Ingredients from the recipe that are NOT available in the pantry.
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

/// Finds recipes that can be made with the pantry contents.
///
/// Matching order per ingredient:
///   1. Same catalogue product id as a pantry item (exact, preferred).
///   2. Normalised name equality or containment (fallback for free text).
///
/// Ingredients without a measurable quantity ("salt to taste") are treated as
/// pantry staples and excluded from the count, so they never make a recipe
/// look incomplete.
class FindRecipesByPantryUseCase {
  final IRecipeRepository _recipeRepository;

  FindRecipesByPantryUseCase(this._recipeRepository);

  /// Returns recipes sorted by ingredient availability (most complete first).
  Future<List<RecipeMatchResult>> call(List<PantryItem> pantryItems) async {
    final recipes = await _recipeRepository.getAllRecipes();
    if (recipes.isEmpty || pantryItems.isEmpty) return [];

    final inStock = pantryItems.where((p) => p.quantity > 0 && !p.isDeleted);
    final pantryProductIds = {
      for (final p in inStock)
        if (p.productId != null) p.productId!,
    };
    final pantryNames = {
      for (final p in inStock) normalizeSeedName(p.name),
    }..remove('');

    final results = <RecipeMatchResult>[];
    for (final recipe in recipes) {
      final counted = recipe.ingredients.where((i) => !i.isOptional).toList();
      if (counted.isEmpty) continue;

      final available = <Ingredient>[];
      final missing = <Ingredient>[];
      for (final ingredient in counted) {
        if (_isAvailable(ingredient, pantryProductIds, pantryNames)) {
          available.add(ingredient);
        } else {
          missing.add(ingredient);
        }
      }
      if (available.isEmpty) continue;

      results.add(RecipeMatchResult(
        recipe: recipe,
        availableIngredients: available,
        missingIngredients: missing,
      ));
    }

    results.sort((a, b) {
      final byPercent = b.percentageAvailable.compareTo(a.percentageAvailable);
      if (byPercent != 0) return byPercent;
      return (a.recipe.name ?? '').compareTo(b.recipe.name ?? '');
    });
    return results;
  }

  bool _isAvailable(
    Ingredient ingredient,
    Set<int> pantryProductIds,
    Set<String> pantryNames,
  ) {
    if (ingredient.productId != null &&
        pantryProductIds.contains(ingredient.productId)) {
      return true;
    }
    final name = normalizeSeedName(ingredient.name);
    if (name.isEmpty) return false;
    for (final pantryName in pantryNames) {
      if (pantryName == name ||
          pantryName.contains(name) ||
          name.contains(pantryName)) {
        return true;
      }
    }
    return false;
  }
}
