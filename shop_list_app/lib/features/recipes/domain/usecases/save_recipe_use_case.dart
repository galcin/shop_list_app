import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';

/// Validates and persists a [Recipe] (insert or update).
///
/// Validation rules:
///   – Title must not be empty.
///   – Must have at least 1 ingredient.
///
/// Side effects:
///   – Editing a built-in recipe hands it over to the user (`isBuiltIn`
///     becomes false) so future seed updates never overwrite their changes.
///   – Free-text ingredients are linked to a catalogue product when one
///     matches by name or alias (only when a product repository is given).
class SaveRecipeUseCase {
  SaveRecipeUseCase(this._repository, [this._products]);
  final IRecipeRepository _repository;
  final IProductRepository? _products;

  Future<Either<Failure, int>> call(Recipe recipe) async {
    final name = recipe.name?.trim() ?? '';
    if (name.isEmpty) {
      return const Left(ValidationFailure('Recipe name must not be empty.'));
    }
    if (recipe.ingredients.isEmpty) {
      return const Left(ValidationFailure('Add at least one ingredient.'));
    }
    try {
      final linked = await _linkIngredients(recipe.ingredients);
      final toSave = recipe.copyWith(
        name: name,
        ingredients: linked,
        isBuiltIn: false,
      );
      final id = await _repository.saveRecipe(toSave);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<List<Ingredient>> _linkIngredients(List<Ingredient> input) async {
    final products = _products;
    if (products == null) return input;
    final out = <Ingredient>[];
    for (final ing in input) {
      if (ing.productId != null || ing.name.trim().isEmpty) {
        out.add(ing);
        continue;
      }
      final match = await products.findByNameOrAlias(ing.name);
      out.add(match?.id != null ? ing.copyWith(productId: match!.id) : ing);
    }
    return out;
  }
}
