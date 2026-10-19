import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/recipes/domain/services/ingredient_aggregator.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';

/// Turns aggregated recipe ingredients into shopping items, resolving the
/// product category for every linked product in a single query.
class ShoppingItemBuilder {
  ShoppingItemBuilder(this._products);
  final IProductRepository _products;

  Future<List<ShoppingItemEntity>> build({
    required int listId,
    required List<AggregatedIngredient> ingredients,
    int startSortOrder = 0,
  }) async {
    final productIds = {
      for (final i in ingredients)
        if (i.productId != null) i.productId!,
    }.toList();
    final products = await _products.getProductsByIds(productIds);
    final categoryByProduct = {
      for (final p in products)
        if (p.id != null) p.id!: p.productCategoryId,
    };

    final now = DateTime.now();
    return [
      for (var i = 0; i < ingredients.length; i++)
        ShoppingItemEntity(
          listId: listId,
          productId: ingredients[i].productId,
          name: ingredients[i].name,
          // Unmeasured staples ("salt to taste") become a single unit-less line.
          quantity: ingredients[i].quantity ?? 1,
          unit: ingredients[i].unit,
          categoryId: categoryByProduct[ingredients[i].productId],
          sortOrder: startSortOrder + i,
          createdAt: now,
        ),
    ];
  }
}
