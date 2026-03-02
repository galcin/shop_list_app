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
        name: Value('Egg Omelet'),
        instructions: Value(
            'Beat 2 eggs, add salt and pepper. Heat butter in a pan, pour eggs and fold when cooked. Serve hot.'),
        prepTime: Value(10),
        favorite: Value(false),
      ),
      RecipesCompanion.insert(
        name: Value('Chicken Soup'),
        instructions: Value(
            'Boil chicken in water with carrots, celery, and onions for 45 minutes. Season with salt and pepper. Add noodles if desired.'),
        prepTime: Value(50),
        favorite: Value(false),
      ),
    ];

    await database.batch((batch) {
      batch.insertAll(database.recipes, defaultRecipes);
    });
  }
}
