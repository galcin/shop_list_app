import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

abstract class IRecipeRepository {
  /// All recipes with their ingredients, ordered by name.
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe?> getRecipeById(int id);

  /// Name/description search, optionally limited to one [category].
  Future<List<Recipe>> searchRecipes(String query, {String? category});

  /// Distinct, sorted recipe categories present in the database.
  Future<List<String>> getCategories();

  Future<int> addRecipe(Recipe recipe);
  Future<bool> updateRecipe(Recipe recipe);
  Future<bool> deleteRecipe(int id);
  Future<int> deleteAllRecipes();
  Future<int> getRecipeCount();
  Future<bool> recipeExists(String name);

  /// Save (insert or update) a recipe and its ingredients. Returns the id.
  Future<int> saveRecipe(Recipe recipe);

  /// Flip only the favourite flag; keeps built-in status untouched.
  Future<bool> setFavorite(int id, bool favorite);

  /// Fetch multiple recipes by their IDs in a single query.
  Future<List<Recipe>> getRecipesByIds(List<int> ids);
}
