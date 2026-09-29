import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/fix_recipe_categories_use_case.dart';

/// Hand-rolled fake implementing [IRecipeRepository]; every member throws
/// [UnimplementedError] unless the test overrides the relevant behavior via
/// the constructor parameters, mirroring the pattern used for the pantry
/// feature's use case tests.
class FakeRecipeRepository implements IRecipeRepository {
  FakeRecipeRepository({this.fixMissingCategoriesError});

  /// When set, [fixMissingCategories] completes with this error instead of
  /// succeeding.
  final Object? fixMissingCategoriesError;

  bool fixMissingCategoriesCalled = false;

  @override
  Future<void> fixMissingCategories() async {
    fixMissingCategoriesCalled = true;
    if (fixMissingCategoriesError != null) {
      throw fixMissingCategoriesError!;
    }
  }

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
  Future<int> saveRecipe(Recipe recipe) async => throw UnimplementedError();

  @override
  Future<List<Recipe>> getRecipesByIds(List<int> ids) async =>
      throw UnimplementedError();
}

void main() {
  group('FixRecipeCategoriesUseCase', () {
    test('returns Right(null) and calls the repository on success', () async {
      final repository = FakeRecipeRepository();
      final useCase = FixRecipeCategoriesUseCase(repository);

      final result = await useCase.call();

      expect(result.isRight(), true);
      expect(repository.fixMissingCategoriesCalled, true);
    });

    test('returns Left(DatabaseFailure) when the repository throws', () async {
      final repository =
          FakeRecipeRepository(fixMissingCategoriesError: Exception('boom'));
      final useCase = FixRecipeCategoriesUseCase(repository);

      final result = await useCase.call();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('boom')),
        (_) => fail('Should have failed'),
      );
    });
  });
}
