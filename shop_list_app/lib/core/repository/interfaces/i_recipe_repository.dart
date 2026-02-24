import '../../../service/models/recipe.dart';

abstract class IRecipeRepository {
  // Get all recipes
  Future<List<Recipe>> getAllRecipes();

  // Get recipe by ID
  Future<Recipe?> getRecipeById(int id);

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query);

  // Add a new recipe
  Future<int> addRecipe(Recipe recipe);

  // Update an existing recipe
  Future<bool> updateRecipe(Recipe recipe);

  // Delete a recipe
  Future<bool> deleteRecipe(int id);

  // Delete all recipes
  Future<int> deleteAllRecipes();

  // Get recipe count
  Future<int> getRecipeCount();

  // Check if recipe with name exists
  Future<bool> recipeExists(String name);
}
