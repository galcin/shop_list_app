import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/recipes/data/repositories/recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/delete_recipe_use_case.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/get_all_recipes_use_case.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/get_recipe_by_id_use_case.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/save_recipe_use_case.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/search_recipes_use_case.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/scale_recipe_use_case.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final recipeRepositoryProvider = Provider<IRecipeRepository>((ref) {
  return RecipeRepository(ref.watch(databaseProvider));
});

// ── Use-case providers ────────────────────────────────────────────────────────

final getAllRecipesUseCaseProvider = Provider<GetAllRecipesUseCase>((ref) {
  return GetAllRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final getRecipeByIdUseCaseProvider = Provider<GetRecipeByIdUseCase>((ref) {
  return GetRecipeByIdUseCase(ref.watch(recipeRepositoryProvider));
});

final saveRecipeUseCaseProvider = Provider<SaveRecipeUseCase>((ref) {
  return SaveRecipeUseCase(ref.watch(recipeRepositoryProvider));
});

final deleteRecipeUseCaseProvider = Provider<DeleteRecipeUseCase>((ref) {
  return DeleteRecipeUseCase(ref.watch(recipeRepositoryProvider));
});

final searchRecipesUseCaseProvider = Provider<SearchRecipesUseCase>((ref) {
  return SearchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final scaleRecipeUseCaseProvider = Provider<ScaleRecipeUseCase>((ref) {
  return const ScaleRecipeUseCase();
});

// ── UI state ──────────────────────────────────────────────────────────────────

/// Search query typed by the user on the recipe list page.
final recipeSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Session-only serving count override per recipe id (key = recipe id).
final servingCountProvider =
    StateProvider.autoDispose.family<int, int>((ref, recipeId) => 0);

// ── ViewModel (list) ──────────────────────────────────────────────────────────

final recipeListProvider =
    AsyncNotifierProvider<RecipeListNotifier, List<Recipe>>(
  RecipeListNotifier.new,
);

class RecipeListNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() => _fetchAll();

  Future<List<Recipe>> _fetchAll() async {
    final result = await ref.read(getAllRecipesUseCaseProvider).call();
    return result.fold((f) => throw f, (list) => list);
  }

  Future<Either<Failure, int>> saveRecipe(Recipe recipe) async {
    final result = await ref.read(saveRecipeUseCaseProvider).call(recipe);
    if (result.isRight()) state = await AsyncValue.guard(_fetchAll);
    return result;
  }

  Future<Either<Failure, bool>> deleteRecipe(int id) async {
    final result = await ref.read(deleteRecipeUseCaseProvider).call(id);
    if (result.isRight()) state = await AsyncValue.guard(_fetchAll);
    return result;
  }
}

// ── ViewModel (detail) ────────────────────────────────────────────────────────

/// Fetches a single recipe by [id]. Auto-disposed.
final recipeDetailProvider =
    AsyncNotifierProvider.autoDispose.family<RecipeDetailNotifier, Recipe, int>(
  RecipeDetailNotifier.new,
);

class RecipeDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Recipe, int> {
  @override
  Future<Recipe> build(int arg) async {
    final result = await ref.read(getRecipeByIdUseCaseProvider).call(arg);
    return result.fold((f) => throw f, (r) => r);
  }
}

// ── Filtered list ─────────────────────────────────────────────────────────────

/// Derives the filtered recipe list based on the current search query.
final filteredRecipesProvider =
    Provider.autoDispose<AsyncValue<List<Recipe>>>((ref) {
  final allAsync = ref.watch(recipeListProvider);
  final query = ref.watch(recipeSearchQueryProvider).trim().toLowerCase();

  return allAsync.whenData((recipes) {
    if (query.isEmpty) return recipes;
    return recipes
        .where((r) => (r.name ?? '').toLowerCase().contains(query))
        .toList();
  });
});
