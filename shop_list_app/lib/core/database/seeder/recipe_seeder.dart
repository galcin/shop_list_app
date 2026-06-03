import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class RecipeSeeder {
  static Future<void> seedDefaultRecipes(AppDatabase database) async {
    final existingNames = await database
        .select(database.recipes)
        .get()
        .then((rows) => rows.map((r) => r.name).toSet());

    final jsonStr = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;

    final allRecipes = jsonList.map((raw) {
      final r = raw as Map<String, dynamic>;
      final ingredients =
          (r['ingredients'] as List<dynamic>).cast<Map<String, dynamic>>();
      return RecipesCompanion.insert(
        name: Value(r['name'] as String),
        instructions: Value(r['instructions'] as String? ?? ''),
        prepTime: r['prepTime'] != null
            ? Value(r['prepTime'] as int)
            : const Value.absent(),
        cookTime: r['cookTime'] != null
            ? Value(r['cookTime'] as int)
            : const Value.absent(),
        servings: r['servings'] != null
            ? Value(r['servings'] as int)
            : const Value.absent(),
        favorite: const Value(false),
        ingredientsJson: Value(jsonEncode(ingredients)),
      );
    }).toList();

    // Insert recipes that don't exist yet.
    final toInsert =
        allRecipes.where((r) => !existingNames.contains(r.name.value)).toList();

    if (toInsert.isNotEmpty) {
      await database.batch((batch) {
        batch.insertAll(database.recipes, toInsert);
      });
    }

    // Backfill ingredients for existing recipes that have none.
    for (final recipe in allRecipes) {
      if (existingNames.contains(recipe.name.value) &&
          recipe.ingredientsJson.present &&
          recipe.ingredientsJson.value != null) {
        await (database.update(database.recipes)
              ..where((r) =>
                  r.name.equals(recipe.name.value!) &
                  r.ingredientsJson.isNull()))
            .write(RecipesCompanion(
          ingredientsJson: recipe.ingredientsJson,
        ));
      }
    }
  }
}
