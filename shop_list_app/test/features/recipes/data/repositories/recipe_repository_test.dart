import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/database/app_database.dart' hide Recipe;
import 'package:shop_list_app/features/recipes/data/repositories/recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

void main() {
  late AppDatabase db;
  late RecipeRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RecipeRepository(db);
  });

  tearDown(() => db.close());

  Future<int> seedProduct(String name) async {
    final categoryId = await db.into(db.productCategories).insert(
          ProductCategoriesCompanion.insert(name: 'Cat $name'),
        );
    return db.into(db.products).insert(ProductsCompanion.insert(
          name: name,
          productCategoryId: categoryId,
        ));
  }

  test('save and load round-trips ingredients in order', () async {
    final eggsId = await seedProduct('Eggs');
    final id = await repo.saveRecipe(Recipe(
      name: 'Omelet',
      category: 'Breakfast',
      servings: 1,
      tags: const ['quick'],
      ingredients: [
        Ingredient(productId: eggsId, name: 'Eggs', quantity: 2, unit: 'pcs'),
        const Ingredient(name: 'Salt', note: 'to taste'),
        const Ingredient(name: 'Butter', quantity: 1, unit: 'tbsp'),
      ],
    ));

    final loaded = await repo.getRecipeById(id);

    expect(loaded, isNotNull);
    expect(loaded!.tags, ['quick']);
    expect(loaded.ingredients.map((i) => i.name), ['Eggs', 'Salt', 'Butter']);
    expect(loaded.ingredients.first.productId, eggsId);
    expect(loaded.ingredients[1].quantity, isNull);
    expect(loaded.ingredients[1].note, 'to taste');
    expect(loaded.createdAt, isNotNull);
  });

  test('updating replaces the ingredient list', () async {
    final id = await repo.saveRecipe(const Recipe(name: 'Toast', ingredients: [
      Ingredient(name: 'Bread', quantity: 2, unit: 'slice'),
      Ingredient(name: 'Butter', quantity: 1, unit: 'tbsp'),
    ]));

    await repo.saveRecipe(Recipe(id: id, name: 'Toast', ingredients: const [
      Ingredient(name: 'Bread', quantity: 1, unit: 'slice'),
    ]));

    final loaded = await repo.getRecipeById(id);
    expect(loaded!.ingredients, hasLength(1));
    expect(loaded.ingredients.single.quantity, 1);
    final rows = await db.select(db.recipeIngredients).get();
    expect(rows, hasLength(1), reason: 'no orphan ingredient rows');
  });

  test('deleting a recipe cascades to its ingredients', () async {
    final id = await repo.saveRecipe(const Recipe(name: 'Tea', ingredients: [
      Ingredient(name: 'Tea bag', quantity: 1, unit: 'pcs'),
    ]));

    expect(await repo.deleteRecipe(id), isTrue);

    expect(await db.select(db.recipeIngredients).get(), isEmpty);
    expect(await repo.getRecipeCount(), 0);
  });

  test('deleting a product unlinks ingredients instead of failing', () async {
    final productId = await seedProduct('Feta');
    final id = await repo.saveRecipe(Recipe(name: 'Salad', ingredients: [
      Ingredient(productId: productId, name: 'Feta', quantity: 100, unit: 'g'),
    ]));

    await (db.delete(db.products)..where((t) => t.id.equals(productId))).go();

    final loaded = await repo.getRecipeById(id);
    expect(loaded!.ingredients.single.productId, isNull);
    expect(loaded.ingredients.single.name, 'Feta');
  });

  test('setFavorite only touches the flag', () async {
    final id = await repo.saveRecipe(const Recipe(
      name: 'Soup',
      isBuiltIn: true,
      seedKey: 'soup',
      ingredients: [Ingredient(name: 'Water', quantity: 1, unit: 'l')],
    ));

    expect(await repo.setFavorite(id, true), isTrue);

    final loaded = await repo.getRecipeById(id);
    expect(loaded!.favorite, isTrue);
    expect(loaded.isBuiltIn, isTrue);
    expect(loaded.seedKey, 'soup');
  });

  test('search and categories work in SQL', () async {
    await repo.saveRecipe(const Recipe(
        name: 'Tomato Soup',
        category: 'Soups',
        description: 'Creamy',
        ingredients: [Ingredient(name: 'Tomatoes', quantity: 4, unit: 'pcs')]));
    await repo.saveRecipe(const Recipe(
        name: 'Pancakes',
        category: 'Breakfast',
        ingredients: [Ingredient(name: 'Flour', quantity: 200, unit: 'g')]));

    expect(await repo.getCategories(), ['Breakfast', 'Soups']);
    expect((await repo.searchRecipes('tomato')).single.name, 'Tomato Soup');
    expect((await repo.searchRecipes('creamy')).single.name, 'Tomato Soup');
    expect(await repo.searchRecipes('', category: 'Breakfast'), hasLength(1));
    expect(await repo.searchRecipes('zzz'), isEmpty);
  });
}
