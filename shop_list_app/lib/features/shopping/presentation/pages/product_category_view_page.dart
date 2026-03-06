import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/shared/widgets/async_value_widget.dart';
import 'package:shop_list_app/shared/widgets/empty_state_widget.dart';
import 'package:shop_list_app/shared/widgets/error_state_widget.dart';
import '../../domain/entities/product_category.dart';
import '../providers/product_category_providers.dart';
import '../widgets/category_bottom_sheet.dart';
import 'product_category_detail_page.dart';

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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            color: const Color(0xFF1E1E1E),
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
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
              ? _buildReorderableList(categories)
              : _buildGrid(categories);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        tooltip: 'Add Category',
        onPressed: () => showCreateCategorySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Grid view ──────────────────────────────────────────────────────────────

  Widget _buildGrid(List<ProductCategory> categories) {
    // Extra tile at the end: "New Category"
    final itemCount = categories.length + 1;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i == categories.length) return _buildNewTile();
        return _buildCategoryTile(categories[i]);
      },
    );
  }

  Widget _buildCategoryTile(ProductCategory category) {
    final bg = _parseColor(category.colorHex) ?? const Color(0xFF2A2A2A);
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(category),
      onDismissed: (_) => _handleDeleteDismissed(category),
      child: GestureDetector(
        onLongPress: () => showEditCategorySheet(context, category),
        child: InkWell(
          onTap: () => _openDetail(category),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bg.withValues(alpha: 0.5), width: 1),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Text(
                  category.iconName ?? category.photo ?? '📦',
                  style: const TextStyle(fontSize: 28),
                ),
                const Spacer(),
                // Name
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Trailing edit icon
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => showEditCategorySheet(context, category),
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white38, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewTile() {
    return GestureDetector(
      onTap: () => showCreateCategorySheet(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white24,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white38, size: 32),
            SizedBox(height: 4),
            Text(
              'New',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reorderable list ───────────────────────────────────────────────────────

  Widget _buildReorderableList(List<ProductCategory> categories) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final reordered = [...categories];
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        ref
            .read(productCategoryListProvider.notifier)
            .reorderCategories(reordered.map((c) => c.id).toList());
      },
      itemBuilder: (_, i) {
        final category = categories[i];
        return _buildReorderTile(category, key: ValueKey(category.id));
      },
    );
  }

  Widget _buildReorderTile(ProductCategory category, {required Key key}) {
    final bg = _parseColor(category.colorHex) ?? const Color(0xFF2A2A2A);
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withValues(alpha: 0.4), width: 1),
      ),
      child: ListTile(
        leading: Text(
          category.iconName ?? category.photo ?? '📦',
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: const ReorderableDragStartListener(
          index: 0, // placeholder; ReorderableListView manages this
          child: Icon(Icons.drag_handle, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _openDetail(ProductCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductCategoryDetailPage(category: category),
      ),
    );
  }

  /// Returns [true] (confirm) or [false] (cancel) from the confirmation dialog.
  /// If the category has products, shows an extra warning.
  Future<bool> _confirmDelete(ProductCategory category) async {
    final productCount = await ref
        .read(productCategoryRepositoryProvider)
        .countProductsForCategory(category.id);

    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Delete "${category.name}"?',
              style: const TextStyle(color: Colors.white),
            ),
            content: productCount > 0
                ? Text(
                    'This category has $productCount product(s).\n'
                    'They will become uncategorised.',
                    style: const TextStyle(color: Colors.white70),
                  )
                : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(color: Color(0xFFEF4444))),
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
