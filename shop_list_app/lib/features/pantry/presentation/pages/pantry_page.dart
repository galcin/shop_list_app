import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/presentation/pages/add_pantry_item_bottom_sheet.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';
import 'package:shop_list_app/features/pantry/presentation/widgets/pantry_item_card.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';

class PantryPage extends ConsumerStatefulWidget {
  const PantryPage({super.key});

  @override
  ConsumerState<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends ConsumerState<PantryPage> {
  @override
  Widget build(BuildContext context) {
    final pantryItemsAsync = ref.watch(pantryItemsProvider);
    final groupedItems = ref.watch(groupedPantryItemsProvider);
    final categoriesAsync = ref.watch(productCategoryListProvider);
    final expiringSoonCount = ref.watch(expiringSoonCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry'),
        elevation: 0,
      ),
      body: pantryItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          AppLogger.instance.error('Error loading pantry items',
              error: error, stackTrace: stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading pantry: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(pantryItemsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your pantry is empty',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to track your inventory',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Alert banner for expiring items
              if (expiringSoonCount > 0)
                SliverToBoxAdapter(
                  child: _buildExpiringAlertBanner(context, expiringSoonCount),
                ),
              // Grouped pantry items
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categoryIds = groupedItems.keys.toList();
                    if (index >= categoryIds.length) return null;

                    final categoryId = categoryIds[index];
                    final categoryItems = groupedItems[categoryId] ?? [];

                    return categoriesAsync.maybeWhen(
                      data: (categories) {
                        final category = categories.firstWhere(
                          (c) => c.id == categoryId,
                          orElse: () => ProductCategory(
                            id: categoryId,
                            name: 'Unknown',
                            iconName: '📦',
                            createdAt: DateTime.now(),
                          ),
                        );

                        return _buildCategorySection(
                          context,
                          category,
                          categoryItems,
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                  childCount: groupedItems.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpiringAlertBanner(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F16),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: AppColors.accent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count items expiring within 3 days',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to view →',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    ProductCategory category,
    List<PantryItem> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                if (category.imageName != null)
                  Image.asset(
                    'assets/images/${category.imageName}',
                    width: 24,
                    height: 24,
                  )
                else if (category.iconName != null)
                  Text(
                    category.iconName!,
                    style: const TextStyle(fontSize: 20),
                  )
                else
                  const Text(
                    '📦',
                    style: TextStyle(fontSize: 20),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return PantryItemCard(item: item);
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPantryItemBottomSheet(),
    );
  }
}
