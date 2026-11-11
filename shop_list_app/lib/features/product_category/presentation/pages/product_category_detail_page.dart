// product_category_detail_page.dart
//
// Mirrors the `RecipeDetailPage` convention: a pinned `SliverAppBar` with a
// hero image/emoji background that fades into the content, followed by a
// title + icon badge row (no raw numeric IDs), then the products list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as cat_model;
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/category_bottom_sheet.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_products_section.dart';
import 'package:shop_list_app/features/products/presentation/widgets/create_product_bottom_sheet.dart';

class ProductCategoryDetailPage extends ConsumerStatefulWidget {
  final cat_model.ProductCategory category;

  const ProductCategoryDetailPage({super.key, required this.category});

  @override
  ConsumerState<ProductCategoryDetailPage> createState() =>
      _ProductCategoryDetailPageState();
}

class _ProductCategoryDetailPageState
    extends ConsumerState<ProductCategoryDetailPage> {
  cat_model.ProductCategory get category => widget.category;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color get _accentColor =>
      _parseColor(category.colorHex) ?? Theme.of(context).colorScheme.primary;

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(child: _buildContent(theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category-detail-fab',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        tooltip: 'Add product to this category',
        onPressed: () => showCreateProductSheet(
          context,
          initialCategoryId: category.id,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Hero header ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(ThemeData theme) {
    final accentColor = _accentColor;
    final emoji = category.iconName ?? category.photo ?? '?';
    final imageName = category.imageName;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
          onPressed: () => showEditCategorySheet(context, category),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          onPressed: _deleteCategory,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: accentColor.withValues(alpha: 0.12)),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: imageName != null
                      ? Image.asset(
                          'assets/images/$imageName',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 64)),
                          ),
                        )
                      : Center(
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 64)),
                        ),
                ),
              ),
            ),
            // Fades the hero band into the content surface below it.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, theme.colorScheme.surface],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent(ThemeData theme) {
    final accentColor = _accentColor;
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              category.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              children: [
                _badge(theme, accentColor, Icons.sort_outlined,
                    'Sort order ${category.sortOrder}'),
                if (category.colorHex != null)
                  _badge(theme, accentColor, Icons.palette_outlined,
                      category.colorHex!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(
              indent: 20,
              endIndent: 20,
              color: theme.colorScheme.outlineVariant),
          CategoryProductsSection(
            categoryId: category.id,
            category: category,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _badge(
      ThemeData theme, Color accentColor, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  void _deleteCategory() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This may affect its products.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ref
                  .read(productCategoryListProvider.notifier)
                  .deleteCategory(category.id);
              result.fold(
                (f) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message)));
                },
                (_) {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Category deleted successfully')),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontFamily: 'Poppins'),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
