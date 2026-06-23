import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/meal_planning/domain/repositories/i_meal_plan_repository.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';
import 'package:shop_list_app/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

/// Generates a shopping list from a meal plan by aggregating ingredients from all assigned recipes.
class GenerateShoppingListFromPlanUseCase {
  GenerateShoppingListFromPlanUseCase(
    this._mealPlanRepository,
    this._recipeRepository,
    this._shoppingListRepository,
  );

  final IMealPlanRepository _mealPlanRepository;
  final IRecipeRepository _recipeRepository;
  final IShoppingListRepository _shoppingListRepository;

  /// Creates a shopping list from a meal plan.
  /// Returns the ID of the newly created shopping list.
  Future<int> call({
    required int planId,
    required String listName,
  }) async {
    try {
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Starting for planId=$planId',
      );

      // Get all recipe IDs assigned in the plan
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Fetching recipe IDs',
      );
      final recipeIds = await _mealPlanRepository.getAssignedRecipeIds(planId);
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Found ${recipeIds.length} recipes',
      );

      if (recipeIds.isEmpty) {
        throw Exception('No recipes assigned in this meal plan');
      }

      // Fetch all recipes in a single query (not N queries)
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Fetching recipe details for IDs: $recipeIds',
      );
      final recipes = await _recipeRepository.getRecipesByIds(recipeIds);
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Got ${recipes.length} recipe details',
      );

      if (recipes.isEmpty) {
        throw Exception('Failed to fetch recipe details');
      }

      // Extract and aggregate ingredients
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Aggregating ingredients',
      );
      final aggregatedIngredients = _aggregateIngredients(recipes);
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Aggregated ${aggregatedIngredients.length} unique ingredients',
      );

      if (aggregatedIngredients.isEmpty) {
        AppLogger.instance.info(
          'GenerateShoppingListFromPlanUseCase: No ingredients found, but continuing',
        );
      }

      // Create the shopping list
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Creating shopping list with name: $listName',
      );
      final listId = await _shoppingListRepository.save(
        ShoppingListEntity(
          name: listName.trim().isEmpty ? 'Meal Plan Shopping List' : listName,
          createdAt: DateTime.now(),
        ),
      );
      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Created shopping list with id=$listId',
      );

      if (listId <= 0) {
        throw Exception('Failed to create shopping list');
      }

      // Add items if there are any
      if (aggregatedIngredients.isNotEmpty) {
        AppLogger.instance.info(
          'GenerateShoppingListFromPlanUseCase: Adding ${aggregatedIngredients.length} items to shopping list',
        );
        final itemsToAdd = aggregatedIngredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return ShoppingItemEntity(
            listId: listId,
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            createdAt: DateTime.now(),
            sortOrder: index, // Use index as sort order
          );
        }).toList();

        AppLogger.instance.info(
          'GenerateShoppingListFromPlanUseCase: About to call addItems with ${itemsToAdd.length} items',
        );
        await _shoppingListRepository.addItems(itemsToAdd);
        AppLogger.instance.info(
          'GenerateShoppingListFromPlanUseCase: Successfully added all items',
        );
      } else {
        AppLogger.instance.info(
          'GenerateShoppingListFromPlanUseCase: No items to add (recipes had no ingredients)',
        );
      }

      AppLogger.instance.info(
        'GenerateShoppingListFromPlanUseCase: Complete! Returning listId=$listId',
      );
      return listId;
    } catch (e) {
      AppLogger.instance.error(
        'GenerateShoppingListFromPlanUseCase: Error occurred: $e',
      );
      rethrow;
    }
  }

  /// Aggregates ingredients from multiple recipes.
  /// Same name + same unit → sum quantities.
  /// Different units → kept as separate items.
  List<_AggregatedIngredient> _aggregateIngredients(List<Recipe> recipes) {
    final Map<String, _AggregatedIngredient> aggregationMap = {};

    for (final recipe in recipes) {
      if (recipe.ingredients == null) continue;

      for (final ingredient in recipe.ingredients!) {
        final key = '${ingredient.name.toLowerCase()}|${ingredient.unit}';

        // Parse quantity
        final qty = double.tryParse(ingredient.quantity) ?? 0.0;

        if (aggregationMap.containsKey(key)) {
          // Add to existing
          aggregationMap[key] = aggregationMap[key]!.copyWith(
            quantity: aggregationMap[key]!.quantity + qty,
          );
        } else {
          // Create new entry
          aggregationMap[key] = _AggregatedIngredient(
            name: ingredient.name,
            quantity: qty,
            unit: ingredient.unit,
          );
        }
      }
    }

    return aggregationMap.values.toList();
  }
}

/// Internal helper class for aggregating ingredients.
class _AggregatedIngredient {
  final String name;
  final double quantity;
  final String unit;

  const _AggregatedIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  _AggregatedIngredient copyWith({
    String? name,
    double? quantity,
    String? unit,
  }) {
    return _AggregatedIngredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
