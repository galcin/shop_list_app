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
}
