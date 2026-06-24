import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_slot.dart';
import 'package:shop_list_app/features/meal_planning/presentation/providers/meal_plan_providers.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';

/// Bottom sheet for picking a recipe to assign to a meal slot.
class RecipePickerBottomSheet extends ConsumerStatefulWidget {
  const RecipePickerBottomSheet({
    super.key,
    required this.slot,
  });

  final MealSlot slot;

  @override
  ConsumerState<RecipePickerBottomSheet> createState() =>
      _RecipePickerBottomSheetState();
}

class _RecipePickerBottomSheetState
    extends ConsumerState<RecipePickerBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final recipesAsync = ref.watch(recipeListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select — ${_getMealLabel(widget.slot.mealType)}',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                hintStyle:
                    TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search,
                    color: colors.onSurface.withValues(alpha: 0.6)),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Recipe list
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                final filteredRecipes = _searchQuery.isEmpty
                    ? recipes
                    : recipes
                        .where((recipe) => (recipe.name ?? '')
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                if (filteredRecipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recipes found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Card(
                      color: colors.surfaceContainerHighest,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: recipe.imageUrl != null &&
                                recipe.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.restaurant,
                                        color: Colors.grey),
                                  ),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant,
                                    color: Colors.grey),
                              ),
                        title: Text(
                          recipe.name ?? 'Untitled Recipe',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: recipe.description != null
                            ? Text(
                                recipe.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      colors.onSurface.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFFFF6B35),
                        ),
                        onTap: () async {
                          if (recipe.id != null) {
                            await ref
                                .read(weeklyMealPlanProvider.notifier)
                                .assignRecipe(
                                  slotId: widget.slot.id!,
                                  recipeId: recipe.id!,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading recipes: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMealLabel(dynamic mealType) {
    final typeStr = mealType.toString().split('.').last;
    return typeStr[0].toUpperCase() + typeStr.substring(1);
  }
}
