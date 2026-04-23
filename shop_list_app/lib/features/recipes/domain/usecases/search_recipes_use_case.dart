import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class SearchRecipesUseCase {
  SearchRecipesUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, List<Recipe>>> call(String query) async {
    try {
      if (query.trim().isEmpty) {
        final all = await _repository.getAllRecipes();
        return Right(all);
      }
      final results = await _repository.searchRecipes(query.trim());
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
