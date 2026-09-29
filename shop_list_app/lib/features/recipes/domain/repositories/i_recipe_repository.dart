import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

abstract class IRecipeRepository {
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe?> getRecipeById(int id);
  Future<List<Recipe>> searchRecipes(String query);
  Future<int> addRecipe(Recipe recipe);
  Future<bool> updateRecipe(Recipe recipe);
  Future<bool> deleteRecipe(int id);
  Future<int> deleteAllRecipes();
  Future<int> getRecipeCount();
  Future<bool> recipeExists(String name);

  /// Save (insert or update) a recipe. Returns the persisted recipe id.
  Future<int> saveRecipe(Recipe recipe);

  /// Fetch multiple recipes by their IDs in a single query.
  Future<List<Recipe>> getRecipesByIds(List<int> ids);

  /// Backfills/repairs the `category` field for known recipes whose category
  /// is missing or stale. This is a one-off data-repair operation; the actual
  /// persistence logic lives in the data layer where Drift access belongs.
  Future<void> fixMissingCategories();
}
