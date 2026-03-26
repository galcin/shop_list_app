import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/pages/product_category_detail_page.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/category_bottom_sheet.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_card.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_emoji_image.dart';
import 'package:shop_list_app/features/products/presentation/pages/product_view_page.dart';
import 'package:shop_list_app/shared/widgets/list/app_reorderable_list_view.dart';
import 'package:shop_list_app/shared/widgets/feedback/async_value_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/feedback/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/list/reorderable_emoji_list_tile.dart';

class ProductCategoryViewPage extends ConsumerStatefulWidget {
  const ProductCategoryViewPage({super.key});

  @override
  ConsumerState<ProductCategoryViewPage> createState() =>
      _ProductCategoryViewPageState();
}

class _ProductCategoryViewPageState
    extends ConsumerState<ProductCategoryViewPage> {
  bool _reorderMode = false;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(productCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            color: AppColors.surface,
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'reorder') {
                setState(() => _reorderMode = !_reorderMode);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reorder',
                child: Text(
                  _reorderMode ? 'Done Reordering' : 'Reorder',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: AsyncValueWidget<List<ProductCategory>>(
        value: asyncValue,
        error: (err, st) => ErrorStateWidget(
          message: err is Failure ? err.message : err.toString(),
          onRetry: () => ref.invalidate(productCategoryListProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Tap + to add your first category',
              actionLabel: '+ Add Category',
              onAction: () => showCreateCategorySheet(context),
            );
          }
          return Column(
            children: [
              _buildAllProductsBanner(),
              Expanded(
                child: _reorderMode
                    ? AppReorderableListView<ProductCategory>(
                        items: categories,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          final reordered = [...categories];
                          final item = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, item);
                          ref
                              .read(productCategoryListProvider.notifier)
                              .reorderCategories(
                                  reordered.map((c) => c.id).toList());
                        },
                        itemBuilder: (ctx, i, category) =>
                            ReorderableEmojiListTile(
                          key: ValueKey(category.id),
                          index: i,
                          accentColor: _parseColor(category.colorHex) ??
                              AppColors.primary,
                          emoji: category.iconName ?? category.photo ?? '??',
                          imageName: category.imageName,
                          title: category.name,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (ctx, index) {
                          final cat = categories[index];

                          final accentColor =
                              _parseColor(cat.colorHex) ?? AppColors.primary;
                          final emoji = cat.iconName ?? cat.photo ?? '?';
                          // Stack pattern from movies_ui:
                          // card body is offset right, emoji image overlaid on the left
                          return Dismissible(
                            key: ValueKey(cat.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin:
                                  const EdgeInsets.only(left: 56, bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            confirmDismiss: (_) => _confirmDelete(cat),
                            onDismissed: (_) => _handleDeleteDismissed(cat),
                            child: Stack(
                              children: [
                                CategoryCard(
                                  category: cat,
                                  accentColor: accentColor,
                                  onTap: () => _openDetail(cat),
                                  onLongPress: () =>
                                      showEditCategorySheet(context, cat),
                                ),
                                Positioned(
                                  top: 6,
                                  left: 0,
                                  child: CategoryEmojiImage(
                                    emoji: emoji,
                                    accentColor: accentColor,
                                    imageName: cat.imageName,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Add Category',
        elevation: 4,
        onPressed: () => showCreateCategorySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildAllProductsBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductViewPage()),
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All Products',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(ProductCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductCategoryDetailPage(category: category),
      ),
    );
  }

  Future<bool> _confirmDelete(ProductCategory category) async {
    final productCount = await ref
        .read(productCategoryListProvider.notifier)
        .countProductsForCategory(category.id);

    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Delete "${category.name}"?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: productCount > 0
                ? Text(
                    'This category has $productCount product(s).\n'
                    'They will become uncategorised.',
                    style: const TextStyle(
                      color: AppColors.textBody,
                      fontFamily: 'Poppins',
                    ),
                  )
                : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontFamily: 'Poppins')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleDeleteDismissed(ProductCategory category) {
    ref
        .read(productCategoryListProvider.notifier)
        .deleteCategory(category.id, force: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${category.name}" deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            ref.read(productCategoryListProvider.notifier).createCategory(
                  name: category.name,
                  colorHex: category.colorHex,
                  iconName: category.iconName ?? category.photo,
                );
          },
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
