import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/features/recipes/domain/usecases/find_recipes_by_pantry_use_case.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';

void showRecipesByPantryModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const RecipesByPantrySheet(),
  );
}

class RecipesByPantrySheet extends ConsumerWidget {
  const RecipesByPantrySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final recipesAsync = ref.watch(recipesByPantryProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return recipesAsync.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.no_meals, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No recipes found',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add more items to your pantry to find matching recipes',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipes for Your Pantry',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Found ${recipes.length} recipe${recipes.length == 1 ? '' : 's'} you can make',
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: recipes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final result = recipes[index];
                      return _buildRecipeCard(context, result);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFFF6B35)),
                SizedBox(height: 16),
                Text(
                  'Searching recipes…',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
          error: (e, st) => Center(
            child: Text(
              'Error loading recipes: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, RecipeMatchResult result) {
    final colors = Theme.of(context).colorScheme;
    final percentAvailable = result.percentageAvailable.toStringAsFixed(0);
    final availableCount = result.availableIngredients.length;
    final totalCount =
        result.availableIngredients.length + result.missingIngredients.length;

    final availableColor = _getAvailabilityColor(result.percentageAvailable);

    return GestureDetector(
      onTap: () {
        if (result.recipe.id != null) {
          context.push('/recipes/${result.recipe.id}');
          Navigator.pop(context);
        }
      },
      child: Card(
        color: colors.surface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.recipe.name ?? 'Untitled Recipe',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$availableCount / $totalCount ingredients available',
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: availableColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: availableColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$percentAvailable%',
                      style: TextStyle(
                        color: availableColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (result.missingIngredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Missing ingredients:',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: result.missingIngredients.map((ing) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        ing.name,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvailabilityColor(double percentage) {
    if (percentage == 100) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 50) return Colors.amber;
    return Colors.red;
  }
}
