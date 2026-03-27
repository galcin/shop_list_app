import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/shopping_item_tile.dart';

class ShoppingListDetailPage extends ConsumerWidget {
  const ShoppingListDetailPage({super.key, required this.listId});

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(shoppingListDetailProvider(listId));

    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
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
                                  backgroundColor: colors.surfaceVariant,
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
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
