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
    // Get all recipe IDs assigned in the plan
    final recipeIds = await _mealPlanRepository.getAssignedRecipeIds(planId);

    if (recipeIds.isEmpty) {
      throw Exception('No recipes assigned in this meal plan');
    }

    // Fetch all recipes in a single query (not N queries)
    final recipes = await _recipeRepository.getRecipesByIds(recipeIds);

    // Extract and aggregate ingredients
    final aggregatedIngredients = _aggregateIngredients(recipes);

    if (aggregatedIngredients.isEmpty) {
      throw Exception('No ingredients found in assigned recipes');
    }

    // Create the shopping list
    final listId = await _shoppingListRepository.save(
      ShoppingListEntity(
        name: listName.trim().isEmpty ? 'Meal Plan Shopping List' : listName,
        createdAt: DateTime.now(),
      ),
    );

    if (listId <= 0) {
      throw Exception('Failed to create shopping list');
    }

    // Add all aggregated ingredients as items in bulk (single transaction)
    final itemsToAdd = aggregatedIngredients
        .map((ingredient) => ShoppingItemEntity(
              listId: listId,
              name: ingredient.name,
              quantity: ingredient.quantity,
              unit: ingredient.unit,
              createdAt: DateTime.now(),
            ))
        .toList();

    await _shoppingListRepository.addItems(itemsToAdd);

    return listId;
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
