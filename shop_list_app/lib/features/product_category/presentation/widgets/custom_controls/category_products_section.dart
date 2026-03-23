// category_products_section.dart  –  analogous to movie_detail_cast.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_empty_products.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_product_tile.dart';
import 'package:shop_list_app/features/shopping/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/shopping/presentation/widgets/create_product_bottom_sheet.dart';

/// Products list section for the category detail page.
/// Mirrors `MovieDetailCast` – a focused widget that owns its own data watch
/// and renders a labelled set of rows.
class CategoryProductsSection extends ConsumerWidget {
  final int categoryId;

  const CategoryProductsSection({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const Text(
                'PRODUCTS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
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
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${products.length}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
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
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Products ────────────────────────────────────────────────────
          asyncProducts.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                        .map((p) => CategoryProductTile(product: p))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
