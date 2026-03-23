// product_category_detail_page.dart
//
// Refactored to mirror the `MovieDetailsPage` pattern from movies_ui:
// - The page is a thin scaffold that composes decoupled display widgets.
// - All display widgets live in widgets/custom_controls/.
// - Business-logic callbacks (edit / delete) stay here.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as cat_model;
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/category_bottom_sheet.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_detail_header_poster.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_detail_thumbnail.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_products_section.dart';
import 'package:shop_list_app/features/shopping/presentation/widgets/create_product_bottom_sheet.dart';

class ProductCategoryDetailPage extends ConsumerStatefulWidget {
  final cat_model.ProductCategory category;

  const ProductCategoryDetailPage({super.key, required this.category});

  @override
  ConsumerState<ProductCategoryDetailPage> createState() =>
      _ProductCategoryDetailPageState();
}

class _ProductCategoryDetailPageState
    extends ConsumerState<ProductCategoryDetailPage> {
  cat_model.ProductCategory get category => widget.category;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color get _accentColor => _parseColor(category.colorHex) ?? AppColors.primary;

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () => showEditCategorySheet(context, category),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteCategory,
          ),
        ],
      ),
      // Mirroring MovieDetailsPage: a ListView of decoupled widgets
      body: ListView(
        children: [
          CategoryDetailThumbnail(
              category: category, accentColor: _accentColor),
          CategoryDetailHeaderPoster(
              category: category, accentColor: _accentColor),
          const Divider(indent: 16, endIndent: 16, color: AppColors.divider),
          CategoryProductsSection(categoryId: category.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Product',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        tooltip: 'Add product to this category',
        onPressed: () => showCreateProductSheet(
          context,
          initialCategoryId: category.id,
        ),
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  void _deleteCategory() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This may affect its products.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ref
                  .read(productCategoryListProvider.notifier)
                  .deleteCategory(category.id);
              result.fold(
                (f) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message)));
                },
                (_) {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Category deleted successfully')),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
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
}
