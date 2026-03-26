import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: detailAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
        error: (e, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54),
              const SizedBox(height: 8),
              Text(e.toString(), style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
        data: (list) {
          if (list == null) {
            return const Center(
              child: Text('List not found.',
                  style: TextStyle(color: Colors.white54)),
            );
          }

          final checkedItems = list.items.where((i) => i.isChecked).toList();
          final uncheckedItems = list.items.where((i) => !i.isChecked).toList();
          final progress = list.completionPercent;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF121212),
                foregroundColor: Colors.white,
                pinned: true,
                title: Text(
                  list.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFF2A2A2A),
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFFFF6B35)),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color(0xFFFF6B35),
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
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📋', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'No items yet',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add your first item.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white54,
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
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white38,
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
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        onPressed: () => _showAddItemSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
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
