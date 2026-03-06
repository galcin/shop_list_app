import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/domain/entities/recipes/recipe.dart' as model;
import 'package:shop_list_app/domain/repositories/recipes/i_recipe_repository.dart';

class RecipeRepository implements IRecipeRepository {
  final AppDatabase _database;

  RecipeRepository(this._database);

  @override
  Future<List<model.Recipe>> getAllRecipes() async {
    final recipes = await _database.select(_database.recipes).get();
    return recipes.map((row) => _recipeFromRow(row)).toList();
  }

  @override
  Future<model.Recipe?> getRecipeById(int id) async {
    final recipe = await (_database.select(_database.recipes)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return recipe != null ? _recipeFromRow(recipe) : null;
  }

  @override
  Future<List<model.Recipe>> searchRecipes(String query) async {
    final recipes = await (_database.select(_database.recipes)
          ..where((tbl) => tbl.name.contains(query)))
        .get();
    return recipes.map((row) => _recipeFromRow(row)).toList();
  }

  @override
  Future<int> addRecipe(model.Recipe recipe) async {
    return await _database.into(_database.recipes).insert(
          RecipesCompanion.insert(
            name: Value(recipe.name),
            instructions: Value(recipe.instructions),
            prepTime: Value(recipe.prepTime),
            favorite: Value(recipe.favorite),
          ),
        );
  }

  @override
  Future<bool> updateRecipe(model.Recipe recipe) async {
    if (recipe.id == null) return false;

    final updated = await (_database.update(_database.recipes)
          ..where((tbl) => tbl.id.equals(recipe.id!)))
        .write(
      RecipesCompanion(
        name: Value(recipe.name),
        instructions: Value(recipe.instructions),
        prepTime: Value(recipe.prepTime),
        favorite: Value(recipe.favorite),
      ),
    );
    return updated > 0;
  }

  @override
  Future<bool> deleteRecipe(int id) async {
    final deleted = await (_database.delete(_database.recipes)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    return deleted > 0;
  }

  @override
  Future<int> deleteAllRecipes() async {
    return await _database.delete(_database.recipes).go();
  }

  @override
  Future<int> getRecipeCount() async {
    final count = await _database.select(_database.recipes).get();
    return count.length;
  }

  @override
  Future<bool> recipeExists(String name) async {
    final recipe = await (_database.select(_database.recipes)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return recipe != null;
  }

  // Convert database row to Recipe model
  model.Recipe _recipeFromRow(Recipe row) {
    return model.Recipe(
      id: row.id,
      name: row.name,
      instructions: row.instructions,
      prepTime: row.prepTime,
      favorite: row.favorite,
    );
  }
}
