// product_detail_page.dart
//
// Displays the full details of a single product with working Edit and Delete
// actions.  Converted to ConsumerStatefulWidget so local product state can
// refresh after an edit without re-building the entire tree.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import 'package:shop_list_app/features/shopping/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/shopping/presentation/widgets/create_product_bottom_sheet.dart';
import 'package:shop_list_app/shared/widgets/display/detail_row.dart';
import 'package:shop_list_app/shared/widgets/display/info_row.dart';
import 'package:shop_list_app/shared/widgets/feedback/status_badge.dart';

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

  bool get _isExpired =>
      _product.expirationDate != null &&
      _product.expirationDate!.isBefore(DateTime.now());

  bool get _isExpiringSoon =>
      _product.expirationDate != null &&
      _product.expirationDate!
          .isBefore(DateTime.now().add(const Duration(days: 7)));

  bool get _hasFilePhoto =>
      _product.photo != null &&
      _product.photo!.isNotEmpty &&
      (_product.photo!.startsWith('/') ||
          _product.photo!.startsWith('file://'));

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
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Product',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF181725)),
        ),
        content: Text(
          'Are you sure you want to delete "${_product.name}"?\nThis action cannot be undone.',
          style:
              const TextStyle(fontFamily: 'Poppins', color: Color(0xFF4C4F4D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_product.id != null) {
                final result = await ref
                    .read(productListProvider.notifier)
                    .deleteProduct(_product.id!);
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
              backgroundColor: const Color(0xFFF3603F),
              foregroundColor: Colors.white,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF181725), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Detail',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF181725),
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF181725)),
            tooltip: 'Edit',
            onPressed: _openEditSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF3603F)),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductImage(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.name ?? 'Unnamed Product',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181725)),
                  ),
                  const SizedBox(height: 20),
                  if (_category != null) ...[
                    InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: _category!.name,
                        iconColor: const Color(0xFF53B175)),
                    const SizedBox(height: 16),
                  ],
                  InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Default Unit',
                      value:
                          '${_product.quantity ?? 1} ${_product.units ?? ''}',
                      iconColor: const Color(0xFF53B175)),
                  const SizedBox(height: 16),
                  if (_product.expirationDate != null) ...[
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Expiration Date',
                      value: _formatDate(_product.expirationDate!),
                      iconColor: _isExpired
                          ? const Color(0xFFF3603F)
                          : _isExpiringSoon
                              ? const Color(0xFFF8A44C)
                              : const Color(0xFF7C7C7C),
                      valueColor: _isExpired
                          ? const Color(0xFFF3603F)
                          : _isExpiringSoon
                              ? const Color(0xFFF8A44C)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    if (_isExpired || _isExpiringSoon)
                      StatusBadge(
                        label: _isExpired ? 'Expired' : 'Expiring Soon',
                        color: _isExpired
                            ? const Color(0xFFF3603F)
                            : const Color(0xFFF8A44C),
                      ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F2),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Additional Information',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181725))),
                        const SizedBox(height: 12),
                        DetailRow(
                            label: 'Product ID',
                            value: '${_product.id ?? 'N/A'}'),
                        if (_product.productCategoryId != null)
                          DetailRow(
                              label: 'Category ID',
                              value: '${_product.productCategoryId}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFF3603F), size: 18),
                      label: const Text('Delete Product',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFFF3603F),
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFF3603F), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF2F3F2)),
      child: Center(child: _buildImageContent()),
    );
  }

  Widget _buildImageContent() {
    final photo = _product.photo;
    if (photo == null || photo.isEmpty) {
      return const Icon(Icons.shopping_bag_outlined,
          size: 80, color: Color(0xFFDBDBDB));
    }
    if (_hasFilePhoto) {
      final file = File(photo.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file,
            fit: BoxFit.contain,
            height: 220,
            errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Color(0xFFDBDBDB)));
      }
    }
    return Text(photo, style: const TextStyle(fontSize: 110));
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
