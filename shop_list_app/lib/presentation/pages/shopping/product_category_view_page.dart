import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/shared/widgets/app_grid_view.dart';
import 'package:shop_list_app/shared/widgets/app_reorderable_list_view.dart';
import 'package:shop_list_app/shared/widgets/async_value_widget.dart';
import 'package:shop_list_app/shared/widgets/dismissible_emoji_card.dart';
import 'package:shop_list_app/shared/widgets/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/error_state_widget.dart';
import 'package:shop_list_app/shared/widgets/reorderable_emoji_list_tile.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/presentation/providers/shopping/product_category_providers.dart';
import 'package:shop_list_app/presentation/widgets/shopping/category_bottom_sheet.dart';
import 'package:shop_list_app/presentation/pages/shopping/product_category_detail_page.dart';

class ProductCategoryViewPage extends ConsumerStatefulWidget {
  const ProductCategoryViewPage({super.key});

  @override
  ConsumerState<ProductCategoryViewPage> createState() =>
      _ProductCategoryViewPageState();
}

class _ProductCategoryViewPageState
    extends ConsumerState<ProductCategoryViewPage> {
  bool _reorderMode = false;

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
          return _reorderMode
              ? AppReorderableListView<ProductCategory>(
                  items: categories,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final reordered = [...categories];
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    ref
                        .read(productCategoryListProvider.notifier)
                        .reorderCategories(reordered.map((c) => c.id).toList());
                  },
                  itemBuilder: (ctx, i, category) => ReorderableEmojiListTile(
                    key: ValueKey(category.id),
                    index: i,
                    accentColor:
                        _parseColor(category.colorHex) ?? AppColors.primary,
                    emoji: category.iconName ?? category.photo ?? '📦',
                    title: category.name,
                  ),
                )
              : AppGridView<ProductCategory>(
                  items: categories,
                  onAddTap: () => showCreateCategorySheet(context),
                  addLabel: 'New Category',
                  itemBuilder: (ctx, category) => DismissibleEmojiCard(
                    itemKey: ValueKey(category.id),
                    accentColor:
                        _parseColor(category.colorHex) ?? AppColors.primary,
                    emoji: category.iconName ?? category.photo ?? '📦',
                    title: category.name,
                    onTap: () => _openDetail(category),
                    onLongPress: () => showEditCategorySheet(context, category),
                    confirmDismiss: (_) => _confirmDelete(category),
                    onDismissed: (_) => _handleDeleteDismissed(category),
                  ),
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

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
        .read(productCategoryRepositoryProvider)
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
