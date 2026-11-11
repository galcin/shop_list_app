// product_detail_page.dart
//
// Displays the full details of a single product. Follows the same
// `SliverAppBar` hero convention as `RecipeDetailPage` /
// `ProductCategoryDetailPage`: a pinned app bar over an image hero that
// fades into the content surface, a title + icon-badge row (no raw numeric
// IDs), themed via `Theme.of(context).colorScheme` so it follows
// Dark/Light/Green.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/presentation/widgets/create_product_bottom_sheet.dart';
import 'package:shop_list_app/features/products/presentation/widgets/product_image_widget.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;
  final ProductCategory? category;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.category,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late Product _product;
  late ProductCategory? _category;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _category = widget.category;
  }

  Color _accentColor(ThemeData theme) =>
      _parseColor(_category?.colorHex) ?? theme.colorScheme.primary;

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  Future<void> _openEditSheet() async {
    await showEditProductSheet(context, _product);
    if (mounted) {
      final updated = ref
          .read(productListProvider)
          .asData
          ?.value
          .where((p) => p.id == _product.id)
          .firstOrNull;
      if (updated != null) setState(() => _product = updated);
    }
  }

  void _confirmDelete() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Product',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${_product.name}"?\nThis action cannot be undone.',
          style: TextStyle(
              fontFamily: 'Poppins', color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_product.id != null) {
                final result = await ref
                    .read(productListProvider.notifier)
                    .deleteProduct(_product.id!);
                if (!mounted) return;
                result.fold(
                  (f) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message))),
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                    Navigator.pop(context);
                  },
                );
              }
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
    );
  }

  // ── Hero header ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(ThemeData theme) {
    final accentColor = _accentColor(theme);

    return SliverAppBar(
      expandedHeight: 240,
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
          tooltip: 'Edit',
          onPressed: _openEditSheet,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          tooltip: 'Delete',
          onPressed: _confirmDelete,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: accentColor.withValues(alpha: 0.12)),
            Center(
              child: Container(
                width: 140,
                height: 140,
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
                  child: ProductImageWidget(
                    photo: _product.photo,
                    size: 140,
                    borderRadius: 28,
                    backgroundColor: Colors.transparent,
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
    final accentColor = _accentColor(theme);
    return Container(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _product.name ?? 'Unnamed product',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_category != null)
                  _badge(theme, accentColor, Icons.category_outlined,
                      _category!.name),
                _badge(theme, accentColor, Icons.inventory_2_outlined,
                    'Sold by ${_product.defaultUnit}'),
                if (_product.aliases.isNotEmpty)
                  _badge(theme, accentColor, Icons.label_outline,
                      _product.aliases.join(', ')),
                if (_product.isBuiltIn)
                  _badge(theme, accentColor, Icons.verified_outlined,
                      'Catalogue product'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(ThemeData theme, Color accentColor, IconData icon, String label,
      {int maxChars = 32}) {
    final text =
        label.length > maxChars ? '${label.substring(0, maxChars)}…' : label;
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
            text,
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
}
