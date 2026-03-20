import 'package:flutter/material.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final ProductCategory? category;

  const ProductDetailPage({
    Key? key,
    required this.product,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpired = product.expirationDate != null &&
        product.expirationDate!.isBefore(DateTime.now());
    final isExpiringSoon = product.expirationDate != null &&
        product.expirationDate!
            .isBefore(DateTime.now().add(const Duration(days: 7)));

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
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF181725)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF3603F)),
            onPressed: () => _showDeleteConfirmation(context),
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
                  // Product Name
                  Text(
                    product.name ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF181725),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  if (category != null) ...[
                    _buildInfoRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: category!.name,
                      iconColor: const Color(0xFF53B175),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quantity
                  _buildInfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Quantity',
                    value: '${product.quantity ?? 0} ${product.units ?? ''}',
                    iconColor: const Color(0xFF53B175),
                  ),
                  const SizedBox(height: 16),

                  // Expiration
                  if (product.expirationDate != null) ...[
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Expiration Date',
                      value: _formatDate(product.expirationDate!),
                      iconColor: isExpired
                          ? const Color(0xFFF3603F)
                          : isExpiringSoon
                              ? const Color(0xFFF8A44C)
                              : const Color(0xFF7C7C7C),
                      valueColor: isExpired
                          ? const Color(0xFFF3603F)
                          : isExpiringSoon
                              ? const Color(0xFFF8A44C)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _buildStatusBadge(isExpired, isExpiringSoon),
                    const SizedBox(height: 20),
                  ],

                  // Additional Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF181725),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Product ID', '${product.id ?? 'N/A'}'),
                        if (product.productCategoryId != null)
                          _buildDetailRow(
                              'Category ID', '${product.productCategoryId}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F2),
      ),
      child: Center(
        child: product.photo != null && product.photo!.isNotEmpty
            ? Text(
                product.photo!,
                style: const TextStyle(fontSize: 110),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 80,
        color: Color(0xFFDBDBDB),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF7C7C7C)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: iconColor ?? const Color(0xFF7C7C7C),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF7C7C7C),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF181725),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF7C7C7C),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181725),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, bool isExpiringSoon) {
    if (!isExpired && !isExpiringSoon) return const SizedBox.shrink();

    final color = isExpired ? const Color(0xFFF3603F) : const Color(0xFFF8A44C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            isExpired ? 'Expired' : 'Expiring Soon',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Product',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF181725),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${product.name}? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF4C4F4D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFF3603F),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
