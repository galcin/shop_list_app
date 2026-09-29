import 'package:flutter_test/flutter_test.dart';
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
  Future<void> fixMissingCategories() async => throw UnimplementedError();

  @override
  Future<List<Recipe>> getAllRecipes() async => throw UnimplementedError();

  @override
  Future<Recipe?> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<Recipe>> searchRecipes(String query) async =>
      throw UnimplementedError();

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
  Future<List<Recipe>> getRecipesByIds(List<int> ids) async =>
      throw UnimplementedError();
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
        Recipe(name: '   ', ingredients: const [
          Ingredient(name: 'Flour', quantity: '1', unit: 'cup'),
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
        Recipe(name: 'Pancakes', ingredients: const []),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('ingredient')),
        (_) => fail('Should have failed'),
      );
    });

    test('saves a valid recipe and returns its id', () async {
      final recipe = Recipe(
        name: 'Pancakes',
        ingredients: const [
          Ingredient(name: 'Flour', quantity: '1', unit: 'cup'),
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
  });
}
