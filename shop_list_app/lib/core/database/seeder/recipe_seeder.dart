import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class RecipeSeeder {
  static String _ing(List<Map<String, dynamic>> items) => jsonEncode(items);

  static Future<void> seedDefaultRecipes(AppDatabase database) async {
    final existingNames = await database
        .select(database.recipes)
        .get()
        .then((rows) => rows.map((r) => r.name).toSet());

    final allRecipes = [
      RecipesCompanion.insert(
        name: const Value('Egg Omelet'),
        instructions: const Value(
            'Beat 2 eggs, add salt and pepper. Heat butter in a pan, pour eggs and fold when cooked. Serve hot.'),
        prepTime: const Value(10),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Eggs', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Butter', 'quantity': '1', 'unit': 'tbsp'},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Chicken Soup'),
        instructions: const Value(
            'Boil chicken in water with carrots, celery, and onions for 45 minutes. Season with salt and pepper. Add noodles if desired.'),
        prepTime: const Value(50),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Chicken', 'quantity': '500', 'unit': 'g'},
          {'name': 'Carrots', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Celery', 'quantity': '2', 'unit': 'stalks'},
          {'name': 'Onion', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Noodles', 'quantity': '100', 'unit': 'g'},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Spaghetti Bolognese'),
        instructions: const Value(
            'Brown 400g minced beef with a chopped onion and 2 garlic cloves. Add a can of crushed tomatoes, 2 tbsp tomato paste, salt, pepper, and dried oregano. Simmer for 20 minutes. Cook spaghetti al dente, drain, and serve topped with the sauce and grated Parmesan.'),
        prepTime: const Value(35),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Minced Beef', 'quantity': '400', 'unit': 'g'},
          {'name': 'Spaghetti', 'quantity': '320', 'unit': 'g'},
          {'name': 'Onion', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Garlic', 'quantity': '2', 'unit': 'cloves'},
          {'name': 'Crushed Tomatoes', 'quantity': '400', 'unit': 'g'},
          {'name': 'Tomato Paste', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Dried Oregano', 'quantity': '1', 'unit': 'tsp'},
          {'name': 'Parmesan', 'quantity': '40', 'unit': 'g'},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Tomato Basil Soup'),
        instructions: const Value(
            'Sauté a chopped onion and 2 garlic cloves in olive oil until soft. Add 600g chopped tomatoes and 400ml vegetable broth. Simmer 20 minutes, then blend until smooth. Stir in fresh basil, salt, and pepper. Serve with crusty bread.'),
        prepTime: const Value(30),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Tomatoes', 'quantity': '600', 'unit': 'g'},
          {'name': 'Onion', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Garlic', 'quantity': '2', 'unit': 'cloves'},
          {'name': 'Vegetable Broth', 'quantity': '400', 'unit': 'ml'},
          {'name': 'Olive Oil', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Fresh Basil', 'quantity': 'handful', 'unit': ''},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Banana Pancakes'),
        instructions: const Value(
            'Mash 2 ripe bananas in a bowl. Mix in 2 eggs, 1/2 cup flour, 1/2 cup milk, and a pinch of salt until smooth. Heat a lightly buttered pan over medium heat. Pour small ladles of batter and cook until bubbles form, then flip. Serve with honey or maple syrup.'),
        prepTime: const Value(20),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Bananas', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Eggs', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Flour', 'quantity': '0.5', 'unit': 'cup'},
          {'name': 'Milk', 'quantity': '0.5', 'unit': 'cup'},
          {'name': 'Butter', 'quantity': '1', 'unit': 'tbsp'},
          {'name': 'Honey', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Salt', 'quantity': 'pinch', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Grilled Cheese Sandwich'),
        instructions: const Value(
            'Butter one side of each of 2 bread slices. Place one slice butter-side-down in a pan over medium heat. Layer with 2 slices of cheese. Top with the second slice butter-side-up. Cook 3 minutes per side until golden and the cheese has melted. Serve immediately.'),
        prepTime: const Value(10),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Bread', 'quantity': '2', 'unit': 'slices'},
          {'name': 'Cheese', 'quantity': '2', 'unit': 'slices'},
          {'name': 'Butter', 'quantity': '1', 'unit': 'tbsp'},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Chicken Stir-Fry'),
        instructions: const Value(
            'Slice 500g chicken breast thin. Heat oil in a wok over high heat, cook chicken 5 minutes. Add sliced bell peppers, carrots, and broccoli. Stir-fry 4 minutes. Mix 3 tbsp soy sauce, 1 tbsp oyster sauce, and 1 tsp sesame oil; pour over. Toss well and serve over steamed rice.'),
        prepTime: const Value(25),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Chicken Breast', 'quantity': '500', 'unit': 'g'},
          {'name': 'Bell Peppers', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Carrots', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Broccoli', 'quantity': '150', 'unit': 'g'},
          {'name': 'Soy Sauce', 'quantity': '3', 'unit': 'tbsp'},
          {'name': 'Oyster Sauce', 'quantity': '1', 'unit': 'tbsp'},
          {'name': 'Sesame Oil', 'quantity': '1', 'unit': 'tsp'},
          {'name': 'Vegetable Oil', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Steamed Rice', 'quantity': '2', 'unit': 'cups'},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Apple Cinnamon Oatmeal'),
        instructions: const Value(
            'Bring 2 cups of milk to a gentle simmer. Stir in 1 cup rolled oats and cook 5 minutes, stirring occasionally. Dice 1 apple and add it along with 1 tsp cinnamon and a pinch of salt. Cook 2 more minutes. Sweeten with honey and serve warm.'),
        prepTime: const Value(15),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Rolled Oats', 'quantity': '1', 'unit': 'cup'},
          {'name': 'Milk', 'quantity': '2', 'unit': 'cups'},
          {'name': 'Apple', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Cinnamon', 'quantity': '1', 'unit': 'tsp'},
          {'name': 'Honey', 'quantity': '1', 'unit': 'tbsp'},
          {'name': 'Salt', 'quantity': 'pinch', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Vegetable Stew'),
        instructions: const Value(
            'Dice and sauté an onion and 2 garlic cloves in olive oil. Add diced potatoes, carrots, celery, and zucchini. Pour in 600ml vegetable broth and a can of diced tomatoes. Season with thyme, rosemary, salt, and pepper. Simmer 30 minutes until vegetables are tender.'),
        prepTime: const Value(45),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Potatoes', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Carrots', 'quantity': '2', 'unit': 'pcs'},
          {'name': 'Celery', 'quantity': '2', 'unit': 'stalks'},
          {'name': 'Zucchini', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Onion', 'quantity': '1', 'unit': 'pcs'},
          {'name': 'Garlic', 'quantity': '2', 'unit': 'cloves'},
          {'name': 'Diced Tomatoes', 'quantity': '400', 'unit': 'g'},
          {'name': 'Vegetable Broth', 'quantity': '600', 'unit': 'ml'},
          {'name': 'Olive Oil', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Dried Thyme', 'quantity': '1', 'unit': 'tsp'},
          {'name': 'Dried Rosemary', 'quantity': '1', 'unit': 'tsp'},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
      RecipesCompanion.insert(
        name: const Value('Caprese Salad'),
        instructions: const Value(
            'Slice 3 large tomatoes and 200g fresh mozzarella into rounds. Alternate tomato and mozzarella slices on a plate. Tuck fresh basil leaves between slices. Drizzle with extra-virgin olive oil and balsamic glaze. Season with salt and freshly ground black pepper.'),
        prepTime: const Value(10),
        favorite: const Value(false),
        ingredientsJson: Value(_ing([
          {'name': 'Tomatoes', 'quantity': '3', 'unit': 'pcs'},
          {'name': 'Fresh Mozzarella', 'quantity': '200', 'unit': 'g'},
          {'name': 'Fresh Basil', 'quantity': 'handful', 'unit': ''},
          {'name': 'Extra-Virgin Olive Oil', 'quantity': '2', 'unit': 'tbsp'},
          {'name': 'Balsamic Glaze', 'quantity': '1', 'unit': 'tbsp'},
          {'name': 'Salt', 'quantity': 'to taste', 'unit': ''},
          {'name': 'Black Pepper', 'quantity': 'to taste', 'unit': ''},
        ])),
      ),
    ];

    final toInsert =
        allRecipes.where((r) => !existingNames.contains(r.name.value)).toList();

    if (toInsert.isNotEmpty) {
      await database.batch((batch) {
        batch.insertAll(database.recipes, toInsert);
      });
    }

    // Update existing recipes that are missing ingredients.
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
