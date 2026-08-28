import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class RecipeSeeder {
  static Future<void> seedDefaultRecipes(AppDatabase database) async {
    debugPrint('[Seeder] ========== Starting Recipe Seeding ==========');

    final existingNames = await database
        .select(database.recipes)
        .get()
        .then((rows) => rows.map((r) => r.name).toSet());

    debugPrint('[Seeder] Found ${existingNames.length} existing recipes in DB');

    final jsonStr = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;

    debugPrint('[Seeder] Loaded ${jsonList.length} recipes from JSON');

    final allRecipes = jsonList.map((raw) {
      final r = raw as Map<String, dynamic>;
      final ingredients =
          (r['ingredients'] as List<dynamic>).cast<Map<String, dynamic>>();

      // Handle instructions as either a List<String> or String
      String instructions = '';
      if (r['instructions'] is List) {
        final steps = (r['instructions'] as List<dynamic>).cast<String>();
        instructions = steps.join('\n');
      } else if (r['instructions'] is String) {
        instructions = r['instructions'] as String;
      }

      // Debug: Log the first few categories
      if (jsonList.indexOf(raw) < 3) {
        debugPrint('[Seeder] Recipe: ${r['name']}, Category: ${r['category']}');
      }

      return RecipesCompanion.insert(
        name: Value(r['name'] as String),
        description: r['description'] != null
            ? Value(r['description'] as String)
            : const Value.absent(),
        category: r['category'] != null
            ? Value(r['category'] as String)
            : const Value.absent(),
        instructions: Value(instructions),
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
        imageUrl: r['imageUrl'] != null
            ? Value(r['imageUrl'] as String)
            : const Value.absent(),
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

      // Backfill imageUrl for existing recipes that have none.
      if (existingNames.contains(recipe.name.value) &&
          recipe.imageUrl.present &&
          recipe.imageUrl.value != null) {
        await (database.update(database.recipes)
              ..where((r) =>
                  r.name.equals(recipe.name.value!) & r.imageUrl.isNull()))
            .write(RecipesCompanion(
          imageUrl: recipe.imageUrl,
        ));
      }

      // Backfill description for existing recipes that have none.
      if (existingNames.contains(recipe.name.value) &&
          recipe.description.present &&
          recipe.description.value != null) {
        await (database.update(database.recipes)
              ..where((r) =>
                  r.name.equals(recipe.name.value!) & r.description.isNull()))
            .write(RecipesCompanion(
          description: recipe.description,
        ));
      }
    }

    // Backfill categories for ALL existing recipes (separate loop for logging)
    debugPrint('[Seeder] Starting category backfill...');
    int categoryUpdateCount = 0;
    for (final recipe in allRecipes) {
      // Backfill category for existing recipes
      if (existingNames.contains(recipe.name.value) &&
          recipe.category.present &&
          recipe.category.value != null) {
        // Always update category to ensure it's current (not just when null)
        final updated = await (database.update(database.recipes)
              ..where((r) => r.name.equals(recipe.name.value!)))
            .write(RecipesCompanion(
          category: recipe.category,
        ));
        if (updated > 0) {
          categoryUpdateCount++;
          if (categoryUpdateCount <= 5) {
            debugPrint(
                '[Seeder] Updated ${recipe.name.value} to category "${recipe.category.value}"');
          }
        }
      }
    }
    debugPrint('[Seeder] Updated $categoryUpdateCount recipes with categories');
    debugPrint('[Seeder] ========== Recipe Seeding Complete ==========');
  }
}
