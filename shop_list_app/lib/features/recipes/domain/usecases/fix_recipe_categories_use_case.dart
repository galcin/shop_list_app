import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Repairs/backfills the `category` field on known recipes whose category is
/// missing or stale.
///
/// This exists as a use case (rather than being invoked directly from the
/// presentation layer against the database) so that presentation code never
/// depends on Drift or data-layer utilities directly, keeping the
/// Presentation → Application → Domain → Data dependency direction intact.
class FixRecipeCategoriesUseCase {
  FixRecipeCategoriesUseCase(this._repository);

  final IRecipeRepository _repository;

  /// Runs the category backfill. Returns [Right] on success or
  /// [Left]\(DatabaseFailure\) if the underlying repository call fails.
  Future<Either<Failure, void>> call() async {
    try {
      await _repository.fixMissingCategories();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
