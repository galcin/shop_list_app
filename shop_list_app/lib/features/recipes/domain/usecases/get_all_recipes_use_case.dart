import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class GetAllRecipesUseCase {
  GetAllRecipesUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, List<Recipe>>> call() async {
    try {
      final recipes = await _repository.getAllRecipes();
      return Right(recipes);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
