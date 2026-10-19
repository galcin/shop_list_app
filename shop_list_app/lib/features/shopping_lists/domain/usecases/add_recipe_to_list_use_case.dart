import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/services/ingredient_aggregator.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/services/shopping_item_builder.dart';

/// Adds all ingredients of one recipe to a shopping list.
///
/// Pass [listId] to append to an existing list, or [newListName] to create
/// one. [servings] scales the quantities (defaults to the recipe's own).
class AddRecipeToListUseCase {
  AddRecipeToListUseCase(
    this._recipes,
    this._lists,
    this._products,
  );

  final IRecipeRepository _recipes;
  final IShoppingListRepository _lists;
  final IProductRepository _products;

  /// Returns the id of the list the items were added to.
  Future<Either<Failure, int>> call({
    required int recipeId,
    int? listId,
    String? newListName,
    int? servings,
  }) async {
    if (listId == null && (newListName == null || newListName.trim().isEmpty)) {
      return const Left(
          ValidationFailure('Choose a shopping list or enter a name.'));
    }
    try {
      final recipe = await _recipes.getRecipeById(recipeId);
      if (recipe == null) {
        return const Left(NotFoundFailure('Recipe not found.'));
      }
      if (recipe.ingredients.isEmpty) {
        return const Left(ValidationFailure('This recipe has no ingredients.'));
      }

      final aggregated = const IngredientAggregator().aggregate(
        [recipe],
        servingsOverride: servings != null ? {recipeId: servings} : const {},
      );

      final targetListId = listId ??
          await _lists.save(ShoppingListEntity(
            name: newListName!.trim(),
            createdAt: DateTime.now(),
          ));
      if (targetListId <= 0) {
        return const Left(DatabaseFailure('Failed to create shopping list'));
      }

      final items = await ShoppingItemBuilder(_products).build(
        listId: targetListId,
        ingredients: aggregated,
        startSortOrder: 1000, // after anything already in the list
      );
      await _lists.addItems(items);
      return Right(targetListId);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
