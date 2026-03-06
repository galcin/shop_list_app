import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class RecipeSeeder {
  static Future<void> seedDefaultRecipes(AppDatabase database) async {
    final existingRecipes = await database.select(database.recipes).get();

    if (existingRecipes.isNotEmpty) {
      return; // Already seeded
    }

    final defaultRecipes = [
      RecipesCompanion.insert(
        name: const Value('Egg Omelet'),
        instructions: const Value(
            'Beat 2 eggs, add salt and pepper. Heat butter in a pan, pour eggs and fold when cooked. Serve hot.'),
        prepTime: const Value(10),
        favorite: const Value(false),
      ),
      RecipesCompanion.insert(
        name: const Value('Chicken Soup'),
        instructions: const Value(
            'Boil chicken in water with carrots, celery, and onions for 45 minutes. Season with salt and pepper. Add noodles if desired.'),
        prepTime: const Value(50),
        favorite: const Value(false),
      ),
    ];

    await database.batch((batch) {
      batch.insertAll(database.recipes, defaultRecipes);
    });
  }
}
