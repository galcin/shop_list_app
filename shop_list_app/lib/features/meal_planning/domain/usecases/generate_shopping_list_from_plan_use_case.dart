import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/recipes/domain/services/ingredient_aggregator.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/services/shopping_item_builder.dart';

/// Generates a shopping list from a meal plan by aggregating the ingredients
/// of every assigned recipe. Items keep their product and category links so
/// the list can be grouped by aisle and show product photos.
class GenerateShoppingListFromPlanUseCase {
  GenerateShoppingListFromPlanUseCase(
    this._mealPlanRepository,
    this._recipeRepository,
    this._shoppingListRepository,
    this._productRepository,
  );

  final IMealPlanRepository _mealPlanRepository;
  final IRecipeRepository _recipeRepository;
  final IShoppingListRepository _shoppingListRepository;
  final IProductRepository _productRepository;

  /// Returns the id of the newly created shopping list on [Right], or a
  /// [ValidationFailure]/[DatabaseFailure] on [Left].
  Future<Either<Failure, int>> call({
    required int planId,
    required String listName,
  }) async {
    try {
      final recipeIds = await _mealPlanRepository.getAssignedRecipeIds(planId);
      if (recipeIds.isEmpty) {
        return const Left(
            ValidationFailure('No recipes assigned in this meal plan'));
      }

      final recipes = await _recipeRepository.getRecipesByIds(recipeIds);
      if (recipes.isEmpty) {
        return const Left(DatabaseFailure('Failed to fetch recipe details'));
      }

      // A recipe planned twice should be shopped for twice.
      final expanded = [
        for (final id in recipeIds)
          ...recipes.where((r) => r.id == id),
      ];
      final aggregated = const IngredientAggregator().aggregate(expanded);

      final listId = await _shoppingListRepository.save(
        ShoppingListEntity(
          name: listName.trim().isEmpty ? 'Meal Plan Shopping List' : listName,
          createdAt: DateTime.now(),
        ),
      );
      if (listId <= 0) {
        return const Left(DatabaseFailure('Failed to create shopping list'));
      }

      final items = await ShoppingItemBuilder(_productRepository)
          .build(listId: listId, ingredients: aggregated);
      if (items.isNotEmpty) {
        await _shoppingListRepository.addItems(items);
      }
      return Right(listId);
    } catch (e) {
      AppLogger.instance
          .error('GenerateShoppingListFromPlanUseCase: Error occurred: $e');
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
