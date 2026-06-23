import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/shopping_item_tile.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';

class ShoppingListDetailPage extends ConsumerWidget {
  const ShoppingListDetailPage({super.key, required this.listId});

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(shoppingListDetailProvider(listId));

    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      bottomNavigationBar: detailAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (list) {
          if (list == null || list.items.every((i) => !i.isChecked)) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                onPressed: () =>
                    _handleCompleteShoppingList(context, ref, list),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Complete & Add to Pantry',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      body: detailAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.error),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list == null) {
            return Center(
              child: Text('List not found.',
                  style: TextStyle(color: colors.onSurfaceVariant)),
            );
          }

          final checkedItems = list.items.where((i) => i.isChecked).toList();
          final uncheckedItems = list.items.where((i) => !i.isChecked).toList();
          final progress = list.completionPercent;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: colors.surface,
                foregroundColor: colors.onSurface,
                pinned: true,
                title: Text(
                  list.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteDialog(context, ref, list),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${list.checkedCount} / ${list.items.length} items',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  valueColor:
                                      AlwaysStoppedAnimation(colors.primary),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Unchecked items
              if (uncheckedItems.isEmpty && checkedItems.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No items yet',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first item.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (uncheckedItems.isNotEmpty)
                  _ItemsSection(
                      items: uncheckedItems, listId: listId, ref: ref),
                if (checkedItems.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Done (${checkedItems.length})',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  _ItemsSection(items: checkedItems, listId: listId, ref: ref),
                ],
              ],
              // Bottom padding so FAB doesn't obscure last item
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () => _showAddItemSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleCompleteShoppingList(
    BuildContext context,
    WidgetRef ref,
    dynamic list,
  ) async {
    if (list.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to complete')),
      );
      return;
    }

    final checkedItems = (list.items as List<ShoppingItemEntity>)
        .where((i) => i.isChecked)
        .toList();
    final uncheckedCount =
        (list.items as List<ShoppingItemEntity>).length - checkedItems.length;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Shopping List?'),
        content: Text(
          checkedItems.isEmpty
              ? 'No items are checked. The list will be closed without adding anything to your Pantry.'
              : uncheckedCount > 0
                  ? 'Add ${checkedItems.length} found item${checkedItems.length == 1 ? '' : 's'} to your Pantry? ($uncheckedCount item${uncheckedCount == 1 ? '' : 's'} not found will be skipped.)'
                  : 'Add all ${checkedItems.length} item${checkedItems.length == 1 ? '' : 's'} to your Pantry?',
          style: TextStyle(color: context.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Complete',
              style: TextStyle(color: context.colorScheme.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // If nothing was checked, just close the list without adding to pantry
    if (checkedItems.isEmpty) {
      try {
        await ref
            .read(shoppingListDetailProvider(listId).notifier)
            .deleteList();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Shopping list closed'),
            backgroundColor: context.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      }
      return;
    }

    try {
      // Call the complete shopping list use case with only checked items
      final result = await ref
          .read(completeShoppingListUseCaseProvider)
          .call(checkedItems);

      if (!context.mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: context.colorScheme.error,
            ),
          );
        },
        (addedCount) {
          // Refresh pantry items
          ref.invalidate(pantryItemsProvider);

          // Delete the shopping list after success
          ref
              .read(shoppingListDetailProvider(listId).notifier)
              .deleteList()
              .then((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    addedCount > 0
                        ? '✅ Added $addedCount item${addedCount == 1 ? '' : 's'} to Pantry'
                        : '✅ Shopping list completed',
                  ),
                  backgroundColor: context.colorScheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            }
          });
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddItemBottomSheet(listId: listId),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic list) {
    final colors = context.colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "${list.name}"? This action cannot be undone.',
          style: TextStyle(color: colors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: colors.primary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await ref
                  .read(shoppingListDetailProvider(listId).notifier)
                  .deleteList();
              if (!context.mounted) return;
              result.fold(
                (f) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(f.message))),
                (_) => Navigator.pop(context),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({
    required this.items,
    required this.listId,
    required this.ref,
  });

  final List<ShoppingItemEntity> items;
  final int listId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final productPhotoById = <int, String?>{};
    asyncProducts.maybeWhen(
      data: (products) {
        for (final product in products) {
          if (product.id != null) {
            productPhotoById[product.id!] = product.photo;
          }
        }
      },
      orElse: () {},
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShoppingItemTile(
                item: item,
                productPhoto: item.productId == null
                    ? null
                    : productPhotoById[item.productId!],
                onToggle: () async {
                  final result = await ref
                      .read(shoppingListDetailProvider(listId).notifier)
                      .toggleChecked(item.id!);
                  if (!context.mounted) return;
                  result.fold(
                    (f) => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(f.message))),
                    (_) {},
                  );
                },
                onDelete: () async {
                  final result = await ref
                      .read(shoppingListDetailProvider(listId).notifier)
                      .removeItem(item.id!);
                  if (!context.mounted) return;
                  result.fold(
                    (f) => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(f.message))),
                    (_) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item removed')),
                    ),
                  );
                },
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
