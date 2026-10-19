import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/save_recipe_use_case.dart';

class FakeRecipeRepository implements IRecipeRepository {
  FakeRecipeRepository({this.nextSaveId = 7});

  final int nextSaveId;
  Recipe? lastSaved;

  @override
  Future<int> saveRecipe(Recipe recipe) async {
    lastSaved = recipe;
    return nextSaveId;
  }

  @override
  Future<List<Recipe>> getAllRecipes() async => throw UnimplementedError();

  @override
  Future<Recipe?> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<Recipe>> searchRecipes(String query, {String? category}) async =>
      throw UnimplementedError();

  @override
  Future<List<String>> getCategories() async => throw UnimplementedError();

  @override
  Future<int> addRecipe(Recipe recipe) async => throw UnimplementedError();

  @override
  Future<bool> updateRecipe(Recipe recipe) async => throw UnimplementedError();

  @override
  Future<bool> deleteRecipe(int id) async => throw UnimplementedError();

  @override
  Future<int> deleteAllRecipes() async => throw UnimplementedError();

  @override
  Future<int> getRecipeCount() async => throw UnimplementedError();

  @override
  Future<bool> recipeExists(String name) async => throw UnimplementedError();

  @override
  Future<bool> setFavorite(int id, bool favorite) async =>
      throw UnimplementedError();

  @override
  Future<List<Recipe>> getRecipesByIds(List<int> ids) async =>
      throw UnimplementedError();
}

/// Product repository that only knows how to resolve names to products.
class FakeProductRepository implements IProductRepository {
  FakeProductRepository(this.byName);
  final Map<String, Product> byName;

  @override
  Future<Product?> findByNameOrAlias(String name) async =>
      byName[name.toLowerCase()];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('SaveRecipeUseCase', () {
    late FakeRecipeRepository repository;
    late SaveRecipeUseCase useCase;

    setUp(() {
      repository = FakeRecipeRepository();
      useCase = SaveRecipeUseCase(repository);
    });

    test('rejects an empty/blank name', () async {
      final result = await useCase.call(
        const Recipe(name: '   ', ingredients: [
          Ingredient(name: 'Flour', quantity: 1, unit: 'cup'),
        ]),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) =>
            expect(failure.message, contains('name must not be empty')),
        (_) => fail('Should have failed'),
      );
    });

    test('rejects a recipe with no ingredients', () async {
      final result = await useCase.call(
        const Recipe(name: 'Pancakes', ingredients: []),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('ingredient')),
        (_) => fail('Should have failed'),
      );
    });

    test('saves a valid recipe and returns its id', () async {
      const recipe = Recipe(
        name: 'Pancakes',
        ingredients: [
          Ingredient(name: 'Flour', quantity: 1, unit: 'cup'),
        ],
      );

      final result = await useCase.call(recipe);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have succeeded'),
        (id) => expect(id, 7),
      );
      expect(repository.lastSaved?.name, 'Pancakes');
    });

    test('editing a built-in recipe hands it over to the user', () async {
      const recipe = Recipe(
        id: 3,
        name: 'Chicken Soup',
        isBuiltIn: true,
        seedKey: 'chicken-soup',
        ingredients: [Ingredient(name: 'Chicken', quantity: 500, unit: 'g')],
      );

      await useCase.call(recipe);

      expect(repository.lastSaved?.isBuiltIn, false);
      // The seed key stays so future seed runs recognise (and skip) it.
      expect(repository.lastSaved?.seedKey, 'chicken-soup');
    });

    test('links free-text ingredients to catalogue products by name',
        () async {
      final products = FakeProductRepository({
        'carrots': const Product(id: 42, name: 'Carrots'),
      });
      useCase = SaveRecipeUseCase(repository, products);

      await useCase.call(const Recipe(
        name: 'Carrot Salad',
        ingredients: [
          Ingredient(name: 'Carrots', quantity: 2, unit: 'pcs'),
          Ingredient(name: 'Mystery Spice', quantity: 1, unit: 'tsp'),
          Ingredient(productId: 9, name: 'Lemon', quantity: 1, unit: 'pcs'),
        ],
      ));

      final saved = repository.lastSaved!.ingredients;
      expect(saved[0].productId, 42);
      expect(saved[1].productId, isNull);
      expect(saved[2].productId, 9, reason: 'existing links are kept');
    });
  });
}
