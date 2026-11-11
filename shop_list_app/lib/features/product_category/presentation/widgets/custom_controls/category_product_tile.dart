// category_product_tile.dart  -  analogous to movie_field.dart
//
// Mirrors the visual language used by `ProductViewPage`'s product rows:
// a circular (round) product image overlapping an `AccentCircleListCard`,
// themed via `Theme.of(context).colorScheme` (so it follows Dark/Light/Green),
// tappable to open `ProductDetailPage`, long-press to edit, swipe to delete.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/presentation/pages/product_detail_page.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/presentation/widgets/create_product_bottom_sheet.dart';
import 'package:shop_list_app/features/products/presentation/widgets/product_image_widget.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

/// A single product row inside the category detail page's products list.
class CategoryProductTile extends ConsumerWidget {
  final Product product;

  /// Accent colour of the parent category (used for the avatar + dot, same
  /// as the rest of the category detail page).
  final Color accentColor;

  /// The category this product belongs to – forwarded to
  /// [ProductDetailPage] so it can show the category name.
  final ProductCategory? category;

  const CategoryProductTile({
    super.key,
    required this.product,
    required this.accentColor,
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('category-product-${product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(left: 56, bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _handleDelete(context, ref),
      child: AccentCircleListCard(
        accentColor: accentColor,
        height: 72,
        onTap: () => _openDetail(context),
        onLongPress: () => showEditProductSheet(context, product),
        circleChild: CircleAccentAvatar(
          accentColor: accentColor,
          size: 72,
          child: ProductImageWidget(
            photo: product.photo,
            size: 72,
            borderRadius: 36,
            backgroundColor: Colors.transparent,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 50, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name ?? 'Unnamed product',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Sold by ${product.defaultUnit}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.isBuiltIn)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Catalogue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation / actions ────────────────────────────────────────────────

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product, category: category),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Delete "${product.name}"?',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'Poppins')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    if (product.id == null) return;
    ref.read(productListProvider.notifier).deleteProduct(product.id!).then(
      (result) {
        if (!context.mounted) return;
        result.fold(
          (f) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${product.name}" deleted')),
          ),
        );
      },
    );
  }
}
