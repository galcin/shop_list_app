import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class GetRecipeByIdUseCase {
  GetRecipeByIdUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, Recipe>> call(int id) async {
    try {
      final recipe = await _repository.getRecipeById(id);
      if (recipe == null)
        return const Left(NotFoundFailure('Recipe not found.'));
      return Right(recipe);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
