import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as cat_model;
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart'
    as prod_model;
import 'package:shop_list_app/features/products/presentation/pages/product_detail_page.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/presentation/widgets/create_product_bottom_sheet.dart';
import 'package:shop_list_app/features/products/presentation/widgets/product_image_widget.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

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
  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categories =
        ref.watch(productCategoryListProvider).asData?.value ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.colorScheme.onSurface, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'All Products',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            color: theme.colorScheme.surface,
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'filter') _showFilterDialog(categories);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list,
                        size: 18, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 10),
                    Text(
                      'Filter by Category',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: asyncProducts.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: theme.colorScheme.error, size: 48),
              const SizedBox(height: 12),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productListProvider),
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary),
                child: Text('Retry',
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontFamily: 'Poppins')),
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
        heroTag: 'products-fab',
        onPressed: () {
          final selectedCategoryId = ref.read(productSelectedCategoryProvider);
          showCreateProductSheet(context,
              initialCategoryId: selectedCategoryId);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        tooltip: 'Add Product',
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -- List -------------------------------------------------------------------

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
    final accentColor =
        _parseColor(cat?.colorHex) ?? Theme.of(context).colorScheme.primary;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(left: 56, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(product),
      onDismissed: (_) => _handleDeleteDismissed(product),
      child: AccentCircleListCard(
        accentColor: accentColor,
        onTap: () => _viewProductDetails(product, cat),
        onLongPress: () => showEditProductSheet(context, product),
        circleChild: CircleAccentAvatar(
          accentColor: accentColor,
          size: 96,
          child: ProductImageWidget(
            photo: product.photo,
            size: 96,
            borderRadius: 48,
            backgroundColor: Colors.transparent,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Product name
              Text(
                product.name ?? 'Unnamed product',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
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
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.quantity != null ||
                            product.units != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${product.quantity ?? 0} ${product.units ?? ''}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expiry badge OR chevron
                  if (_isExpired(product.expirationDate))
                    _expiryBadge('Expired', Theme.of(context).colorScheme.error)
                  else if (_isExpiringSoon(product.expirationDate))
                    _expiryBadge('Exp. ${_formatDate(product.expirationDate!)}',
                        AppColors.accent)
                  else
                    Icon(Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20),
                ],
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
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
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search,
              color: theme.colorScheme.onSurfaceVariant, size: 20),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
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
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
        onChanged: (v) =>
            ref.read(productSearchQueryProvider.notifier).state = v,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_basket_outlined,
                size: 52, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'No products found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // -- Helpers ----------------------------------------------------------------

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
    final theme = Theme.of(context);
    final selectedCategoryId = ref.read(productSelectedCategoryProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Filter by Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Categories',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: theme.colorScheme.onSurface)),
              leading: Radio<int?>(
                value: null,
                groupValue: selectedCategoryId,
                activeColor: theme.colorScheme.primary,
                onChanged: (v) {
                  ref.read(productSelectedCategoryProvider.notifier).state = v;
                  Navigator.pop(context);
                },
              ),
            ),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat.name,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.colorScheme.onSurface)),
                leading: Radio<int?>(
                  value: cat.id,
                  groupValue: selectedCategoryId,
                  activeColor: theme.colorScheme.primary,
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
            child: Text('Close',
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
