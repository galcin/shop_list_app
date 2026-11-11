// category_products_section.dart  –  analogous to movie_detail_cast.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_empty_products.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_product_tile.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/presentation/widgets/create_product_bottom_sheet.dart';

/// Products list section for the category detail page.
/// Mirrors `MovieDetailCast` – a focused widget that owns its own data watch
/// and renders a labelled set of rows.
class CategoryProductsSection extends ConsumerWidget {
  final int categoryId;

  /// The category these products belong to – forwarded to each tile so it
  /// can theme itself with the category accent and open
  /// `ProductDetailPage` with the right category context.
  final ProductCategory category;

  /// Accent colour of [category] (already computed by the parent page),
  /// kept consistent with the header/thumbnail widgets above this section.
  final Color accentColor;

  const CategoryProductsSection({
    super.key,
    required this.categoryId,
    required this.category,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncProducts = ref.watch(categoryProductsProvider(categoryId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRODUCTS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: <Widget>[
                  asyncProducts.maybeWhen(
                    data: (products) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${products.length}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  // Quick-add button in the header
                  GestureDetector(
                    onTap: () => showCreateProductSheet(context,
                        initialCategoryId: categoryId),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 16, color: accentColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Products ────────────────────────────────────────────────────
          asyncProducts.when(
            loading: () => Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary),
            ),
            error: (err, _) => Center(child: Text(err.toString())),
            data: (products) => products.isEmpty
                ? CategoryEmptyProducts(
                    onAdd: () => showCreateProductSheet(
                      context,
                      initialCategoryId: categoryId,
                    ),
                  )
                : Column(
                    children: products
                        .map((p) => CategoryProductTile(
                              product: p,
                              accentColor: accentColor,
                              category: category,
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
