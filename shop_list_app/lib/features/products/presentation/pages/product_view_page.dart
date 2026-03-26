import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as cat_model;
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart'
    as prod_model;
import 'package:shop_list_app/features/shopping/presentation/pages/product_detail_page.dart';
import 'package:shop_list_app/features/shopping/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/shopping/presentation/widgets/create_product_bottom_sheet.dart';
import 'package:shop_list_app/features/shopping/presentation/widgets/product_image_widget.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';

/// Lists all products using the same visual language as the category list:
/// – Stack pattern: card body offset right + circular image/emoji overlay
/// – Dismissible (swipe left) for delete
/// – LongPress to edit
/// – Tap to view detail
class ProductViewPage extends ConsumerStatefulWidget {
  const ProductViewPage({super.key});

  @override
  ConsumerState<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends ConsumerState<ProductViewPage> {
  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categories =
        ref.watch(productCategoryListProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'All Products',
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
              if (v == 'filter') _showFilterDialog(categories);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list,
                        size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text(
                      'Filter by Category',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: asyncProducts.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins', color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productListProvider),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Retry',
                    style: TextStyle(
                        color: AppColors.onPrimary, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
        data: (_) => Column(
          children: [
            _buildSearchBar(),
            if (categories.isNotEmpty) _buildCategoryChips(categories),
            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildProductList(filteredProducts, categories),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final selectedCategoryId = ref.read(productSelectedCategoryProvider);
          showCreateProductSheet(context,
              initialCategoryId: selectedCategoryId);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Add Product',
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildProductList(
    List<prod_model.Product> products,
    List<cat_model.ProductCategory> categories,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _buildProductRow(products[index], categories),
    );
  }

  Widget _buildProductRow(
    prod_model.Product product,
    List<cat_model.ProductCategory> categories,
  ) {
    final match = categories.where((c) => c.id == product.productCategoryId);
    final cat = match.isNotEmpty ? match.first : null;
    final accentColor = _parseColor(cat?.colorHex) ?? AppColors.primary;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(left: 56, bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(product),
      onDismissed: (_) => _handleDeleteDismissed(product),
      child: Stack(
        children: [
          // ── Card body (offset right) ─────────────────────────────────
          GestureDetector(
            onTap: () => _viewProductDetails(product, cat),
            onLongPress: () => showEditProductSheet(context, product),
            child: Container(
              width: double.infinity,
              height: 96,
              margin: const EdgeInsets.only(left: 56, bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 50, right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Product name
                    Text(
                      product.name ?? 'Unnamed product',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Accent dot + category name + qty
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  cat?.name ?? 'No category',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.quantity != null ||
                                  product.units != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${product.quantity ?? 0} ${product.units ?? ''}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Expiry badge OR chevron
                        if (_isExpired(product.expirationDate))
                          _expiryBadge('Expired', AppColors.error)
                        else if (_isExpiringSoon(product.expirationDate))
                          _expiryBadge(
                              'Exp. ${_formatDate(product.expirationDate!)}',
                              AppColors.accent)
                        else
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Circular image overlay (left) ────────────────────────────
          Positioned(
            top: 6,
            left: 0,
            child: CircleAccentAvatar(
              accentColor: accentColor,
              child: ProductImageWidget(
                photo: product.photo,
                size: 84,
                borderRadius: 42,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expiryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<cat_model.ProductCategory> categories) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(null, 'All'),
          ...categories.map((c) => _buildChip(c.id, c.name)),
        ],
      ),
    );
  }

  Widget _buildChip(int? catId, String label) {
    final selected = ref.watch(productSelectedCategoryProvider) == catId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(productSelectedCategoryProvider.notifier).state = catId,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.onPrimary : AppColors.textBody,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (v) =>
            ref.read(productSearchQueryProvider.notifier).state = v,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_basket_outlined,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No products found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isExpired(DateTime? d) => d != null && d.isBefore(DateTime.now());

  bool _isExpiringSoon(DateTime? d) =>
      d != null && d.isBefore(DateTime.now().add(const Duration(days: 7)));

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  Future<bool> _confirmDelete(prod_model.Product product) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Delete "${product.name}"?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
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

  void _handleDeleteDismissed(prod_model.Product product) {
    if (product.id == null) return;
    ref.read(productListProvider.notifier).deleteProduct(product.id!).then(
      (result) {
        if (!mounted) return;
        result.fold(
          (f) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${product.name}" deleted'),
              duration: const Duration(seconds: 4),
            ),
          ),
        );
      },
    );
  }

  void _viewProductDetails(
      prod_model.Product product, cat_model.ProductCategory? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product, category: category),
      ),
    ).then((_) => ref.invalidate(productListProvider));
  }

  void _showFilterDialog(List<cat_model.ProductCategory> categories) {
    final selectedCategoryId = ref.read(productSelectedCategoryProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Filter by Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Categories',
                  style: TextStyle(
                      fontFamily: 'Poppins', color: AppColors.textPrimary)),
              leading: Radio<int?>(
                value: null,
                groupValue: selectedCategoryId,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  ref.read(productSelectedCategoryProvider.notifier).state = v;
                  Navigator.pop(context);
                },
              ),
            ),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat.name,
                    style: const TextStyle(
                        fontFamily: 'Poppins', color: AppColors.textPrimary)),
                leading: Radio<int?>(
                  value: cat.id,
                  groupValue: selectedCategoryId,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    ref.read(productSelectedCategoryProvider.notifier).state =
                        v;
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
