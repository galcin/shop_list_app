import 'package:shop_list_app/core/database/seeder/seed_data.dart'
    show normalizeSeedName;
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

/// One line of a generated shopping list: the merged ingredients of one or
/// more recipes that refer to the same product (or, for free-text
/// ingredients, the same name) in the same unit.
class AggregatedIngredient {
  const AggregatedIngredient({
    required this.name,
    required this.unit,
    this.productId,
    this.quantity,
    this.note,
  });

  final int? productId;
  final String name;

  /// Null when none of the merged lines had a measurable quantity.
  final double? quantity;
  final String unit;
  final String? note;

  AggregatedIngredient merge(Ingredient other) {
    final a = quantity;
    final b = other.quantity;
    return AggregatedIngredient(
      productId: productId ?? other.productId,
      name: name,
      unit: unit,
      quantity: a == null ? b : (b == null ? a : a + b),
      note: note ?? other.note,
    );
  }
}

/// Merges ingredient lines across recipes.
///
/// Lines are grouped by product id when available, otherwise by normalised
/// name, and always by unit: 200 g flour + 300 g flour → 500 g flour, while
/// 1 cup flour stays a separate line because units are not converted.
class IngredientAggregator {
  const IngredientAggregator();

  List<AggregatedIngredient> aggregate(
    Iterable<Recipe> recipes, {
    /// Serving count to scale each recipe to, keyed by recipe id.
    Map<int, int> servingsOverride = const {},
  }) {
    final result = <String, AggregatedIngredient>{};
    for (final recipe in recipes) {
      final target = recipe.id != null ? servingsOverride[recipe.id!] : null;
      final scaled = target != null ? recipe.scaleServings(target) : recipe;
      for (final ing in scaled.ingredients) {
        final identity = ing.productId != null
            ? 'p:${ing.productId}'
            : 'n:${normalizeSeedName(ing.name)}';
        final key = '$identity|${ing.unit}';
        final existing = result[key];
        result[key] = existing == null
            ? AggregatedIngredient(
                productId: ing.productId,
                name: ing.name,
                unit: ing.unit,
                quantity: ing.quantity,
                note: ing.note,
              )
            : existing.merge(ing);
      }
    }
    return result.values.toList();
  }
}
