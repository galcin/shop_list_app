import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Distinct recipe categories currently in the database, sorted by name.
class GetRecipeCategoriesUseCase {
  GetRecipeCategoriesUseCase(this._repository);
  final IRecipeRepository _repository;

  Future<Either<Failure, List<String>>> call() async {
    try {
      return Right(await _repository.getCategories());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
