import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Validates and persists a [Recipe] (insert or update).
///
/// Validation rules:
///   – Title must not be empty.
///   – Must have at least 1 ingredient.
class SaveRecipeUseCase {
  SaveRecipeUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, int>> call(Recipe recipe) async {
    final name = recipe.name?.trim() ?? '';
    if (name.isEmpty) {
      return const Left(ValidationFailure('Recipe name must not be empty.'));
    }
    if (recipe.ingredients == null || recipe.ingredients!.isEmpty) {
      return const Left(ValidationFailure('Add at least one ingredient.'));
    }
    try {
      final id = await _repository.saveRecipe(recipe);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
