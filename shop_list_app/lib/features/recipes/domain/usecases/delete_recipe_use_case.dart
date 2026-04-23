import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

class DeleteRecipeUseCase {
  DeleteRecipeUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, bool>> call(int id) async {
    try {
      final deleted = await _repository.deleteRecipe(id);
      return Right(deleted);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
