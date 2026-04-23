import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart'
    as model;
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class RecipeRepository implements IRecipeRepository {
  final AppDatabase _database;

  RecipeRepository(this._database);

  @override
  Future<List<model.Recipe>> getAllRecipes() async {
    final rows = await _database.select(_database.recipes).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<model.Recipe?> getRecipeById(int id) async {
    final row = await (_database.select(_database.recipes)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<List<model.Recipe>> searchRecipes(String query) async {
    final rows = await (_database.select(_database.recipes)
          ..where((t) => t.name.contains(query)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<int> addRecipe(model.Recipe recipe) async {
    return _database.into(_database.recipes).insert(
          RecipesCompanion.insert(
            name: Value(recipe.name),
            description: Value(recipe.description),
            instructions: Value(recipe.instructions),
            prepTime: Value(recipe.prepTime),
            cookTime: Value(recipe.cookTime),
            servings: Value(recipe.servings),
            favorite: Value(recipe.favorite),
            imageUrl: Value(recipe.imageUrl),
            rating: Value(recipe.rating),
            tagsJson:
                Value(recipe.tags != null ? jsonEncode(recipe.tags) : null),
            ingredientsJson: Value(recipe.ingredients != null
                ? jsonEncode(recipe.ingredients!.map((i) => i.toMap()).toList())
                : null),
          ),
        );
  }

  @override
  Future<bool> updateRecipe(model.Recipe recipe) async {
    if (recipe.id == null) return false;
    final updated = await (_database.update(_database.recipes)
          ..where((t) => t.id.equals(recipe.id!)))
        .write(
      RecipesCompanion(
        name: Value(recipe.name),
        description: Value(recipe.description),
        instructions: Value(recipe.instructions),
        prepTime: Value(recipe.prepTime),
        cookTime: Value(recipe.cookTime),
        servings: Value(recipe.servings),
        favorite: Value(recipe.favorite),
        imageUrl: Value(recipe.imageUrl),
        rating: Value(recipe.rating),
        tagsJson: Value(recipe.tags != null ? jsonEncode(recipe.tags) : null),
        ingredientsJson: Value(recipe.ingredients != null
            ? jsonEncode(recipe.ingredients!.map((i) => i.toMap()).toList())
            : null),
      ),
    );
    return updated > 0;
  }

  @override
  Future<int> saveRecipe(model.Recipe recipe) async {
    if (recipe.id != null) {
      await updateRecipe(recipe);
      return recipe.id!;
    }
    return addRecipe(recipe);
  }

  @override
  Future<bool> deleteRecipe(int id) async {
    final deleted = await (_database.delete(_database.recipes)
          ..where((t) => t.id.equals(id)))
        .go();
    return deleted > 0;
  }

  @override
  Future<int> deleteAllRecipes() async {
    return _database.delete(_database.recipes).go();
  }

  @override
  Future<int> getRecipeCount() async {
    final list = await _database.select(_database.recipes).get();
    return list.length;
  }

  @override
  Future<bool> recipeExists(String name) async {
    final row = await (_database.select(_database.recipes)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    return row != null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  model.Recipe _fromRow(Recipe row) {
    List<model.Ingredient>? ingredients;
    if (row.ingredientsJson != null) {
      try {
        final raw = jsonDecode(row.ingredientsJson!) as List<dynamic>;
        ingredients = raw
            .map((e) => model.Ingredient.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    List<String>? tags;
    if (row.tagsJson != null) {
      try {
        final raw = jsonDecode(row.tagsJson!) as List<dynamic>;
        tags = raw.cast<String>();
      } catch (_) {}
    }
    return model.Recipe(
      id: row.id,
      name: row.name,
      description: row.description,
      instructions: row.instructions,
      prepTime: row.prepTime,
      cookTime: row.cookTime,
      servings: row.servings,
      favorite: row.favorite,
      imageUrl: row.imageUrl,
      rating: row.rating,
      tags: tags,
      ingredients: ingredients,
    );
  }
}
