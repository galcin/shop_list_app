import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Sets the favourite flag of a recipe without touching anything else, so a
/// built-in recipe stays built-in when the user stars it.
class ToggleFavoriteRecipeUseCase {
  ToggleFavoriteRecipeUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, bool>> call(int id, bool favorite) async {
    try {
      final ok = await _repository.setFavorite(id, favorite);
      if (!ok) return const Left(NotFoundFailure('Recipe not found.'));
      return Right(favorite);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
