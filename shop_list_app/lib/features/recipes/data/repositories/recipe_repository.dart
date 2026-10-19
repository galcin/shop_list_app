import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart'
    as model;
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class RecipeRepository implements IRecipeRepository {
  final AppDatabase _db;

  RecipeRepository(this._db);

  // ── Queries ────────────────────────────────────────────────────────────────

  @override
  Future<List<model.Recipe>> getAllRecipes() async {
    final rows = await (_db.select(_db.recipes)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return _attachIngredients(rows);
  }

  @override
  Future<model.Recipe?> getRecipeById(int id) async {
    final row = await (_db.select(_db.recipes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _attachIngredients([row])).first;
  }

  @override
  Future<List<model.Recipe>> searchRecipes(String query,
      {String? category}) async {
    final q = _db.select(_db.recipes)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      q.where((t) => t.name.contains(trimmed) | t.description.contains(trimmed));
    }
    if (category != null && category.isNotEmpty) {
      q.where((t) => t.category.equals(category));
    }
    return _attachIngredients(await q.get());
  }

  @override
  Future<List<String>> getCategories() async {
    final rows = await _db.customSelect(
      'SELECT DISTINCT category FROM recipes '
      "WHERE category IS NOT NULL AND TRIM(category) != '' "
      'ORDER BY category',
      readsFrom: {_db.recipes},
    ).get();
    return rows.map((r) => r.read<String>('category')).toList();
  }

  @override
  Future<List<model.Recipe>> getRecipesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (_db.select(_db.recipes)..where((t) => t.id.isIn(ids)))
        .get();
    return _attachIngredients(rows);
  }

  @override
  Future<int> getRecipeCount() async {
    final count = _db.recipes.id.count();
    final row = await (_db.selectOnly(_db.recipes)..addColumns([count]))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<bool> recipeExists(String name) async {
    final row = await (_db.select(_db.recipes)
          ..where((t) => t.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  @override
  Future<int> addRecipe(model.Recipe recipe) {
    return _db.transaction(() async {
      final id = await _db.into(_db.recipes).insert(_toCompanion(recipe));
      await _replaceIngredients(id, recipe.ingredients);
      return id;
    });
  }

  @override
  Future<bool> updateRecipe(model.Recipe recipe) {
    final id = recipe.id;
    if (id == null) return Future.value(false);
    return _db.transaction(() async {
      final updated = await (_db.update(_db.recipes)
            ..where((t) => t.id.equals(id)))
          .write(_toCompanion(recipe, forUpdate: true));
      if (updated == 0) return false;
      await _replaceIngredients(id, recipe.ingredients);
      return true;
    });
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
  Future<bool> setFavorite(int id, bool favorite) async {
    final updated = await (_db.update(_db.recipes)
          ..where((t) => t.id.equals(id)))
        .write(RecipesCompanion(
      favorite: Value(favorite),
      updatedAt: Value(DateTime.now()),
    ));
    return updated > 0;
  }

  @override
  Future<bool> deleteRecipe(int id) async {
    // recipe_ingredients rows cascade via the foreign key.
    final deleted =
        await (_db.delete(_db.recipes)..where((t) => t.id.equals(id))).go();
    return deleted > 0;
  }

  @override
  Future<int> deleteAllRecipes() => _db.delete(_db.recipes).go();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _replaceIngredients(
      int recipeId, List<model.Ingredient> ingredients) async {
    await (_db.delete(_db.recipeIngredients)
          ..where((t) => t.recipeId.equals(recipeId)))
        .go();
    if (ingredients.isEmpty) return;
    await _db.batch((b) {
      b.insertAll(_db.recipeIngredients, [
        for (var i = 0; i < ingredients.length; i++)
          RecipeIngredientsCompanion.insert(
            recipeId: recipeId,
            productId: Value(ingredients[i].productId),
            name: ingredients[i].name,
            quantity: Value(ingredients[i].quantity),
            unit: Value(ingredients[i].unit),
            note: Value(ingredients[i].note),
            sortOrder: Value(i),
          ),
      ]);
    });
  }

  Future<List<model.Recipe>> _attachIngredients(List<Recipe> rows) async {
    if (rows.isEmpty) return [];
    final ids = rows.map((r) => r.id).toList();
    final ingredientRows = await (_db.select(_db.recipeIngredients)
          ..where((t) => t.recipeId.isIn(ids))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    final byRecipe = <int, List<model.Ingredient>>{};
    for (final row in ingredientRows) {
      byRecipe.putIfAbsent(row.recipeId, () => []).add(_ingredientFromRow(row));
    }
    return rows.map((r) => _fromRow(r, byRecipe[r.id] ?? const [])).toList();
  }

  RecipesCompanion _toCompanion(model.Recipe recipe, {bool forUpdate = false}) {
    final now = DateTime.now();
    return RecipesCompanion(
      name: Value(recipe.name),
      description: Value(recipe.description),
      category: Value(recipe.category),
      instructions: Value(recipe.instructions),
      prepTime: Value(recipe.prepTime),
      cookTime: Value(recipe.cookTime),
      servings: Value(recipe.servings),
      favorite: Value(recipe.favorite),
      imageUrl: Value(recipe.imageUrl),
      rating: Value(recipe.rating),
      tagsJson: Value(recipe.tags.isEmpty ? null : jsonEncode(recipe.tags)),
      isBuiltIn: Value(recipe.isBuiltIn),
      seedKey: Value(recipe.seedKey),
      updatedAt: Value(now),
      createdAt: forUpdate ? const Value.absent() : Value(now),
    );
  }

  model.Ingredient _ingredientFromRow(RecipeIngredient row) => model.Ingredient(
        id: row.id,
        productId: row.productId,
        name: row.name,
        quantity: row.quantity,
        unit: row.unit,
        note: row.note,
      );

  model.Recipe _fromRow(Recipe row, List<model.Ingredient> ingredients) {
    List<String> tags = const [];
    if (row.tagsJson != null) {
      try {
        tags = (jsonDecode(row.tagsJson!) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } catch (_) {}
    }
    return model.Recipe(
      id: row.id,
      name: row.name,
      description: row.description,
      category: row.category,
      instructions: row.instructions,
      prepTime: row.prepTime,
      cookTime: row.cookTime,
      servings: row.servings,
      favorite: row.favorite,
      imageUrl: row.imageUrl,
      rating: row.rating,
      tags: tags,
      ingredients: ingredients,
      isBuiltIn: row.isBuiltIn,
      seedKey: row.seedKey,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
