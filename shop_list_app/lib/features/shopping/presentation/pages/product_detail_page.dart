import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

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
        product.expirationDate!.isBefore(DateTime.now().add(Duration(days: 7)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            _buildProductImage(),

            // Product Information
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name ?? 'Unnamed Product',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Category
                  if (category != null) ...[
                    _buildInfoRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: category!.name,
                      iconColor: Colors.blue,
                    ),
                    SizedBox(height: 16),
                  ],

                  // Quantity
                  _buildInfoRow(
                    icon: Icons.inventory_2,
                    label: 'Quantity',
                    value: '${product.quantity ?? 0} ${product.units ?? ''}',
                    iconColor: Colors.green,
                  ),
                  SizedBox(height: 16),

                  // Expiration Date
                  if (product.expirationDate != null) ...[
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Expiration Date',
                      value: _formatDate(product.expirationDate!),
                      iconColor: isExpired
                          ? Colors.red
                          : isExpiringSoon
                              ? Colors.orange
                              : Colors.grey,
                      valueColor: isExpired
                          ? Colors.red
                          : isExpiringSoon
                              ? Colors.orange
                              : null,
                    ),
                    SizedBox(height: 16),

                    // Status Badge
                    _buildStatusBadge(isExpired, isExpiringSoon),
                    SizedBox(height: 24),
                  ],

                  // Additional Information Card
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                              'Product ID', '${product.id ?? 'N/A'}'),
                          if (product.productCategoryId != null)
                            _buildDetailRow(
                                'Category ID', '${product.productCategoryId}'),
                        ],
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
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Center(
        child: product.photo != null && product.photo!.isNotEmpty
            ? Text(
                product.photo!,
                style: TextStyle(fontSize: 120),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.shopping_bag,
        size: 80,
        color: Colors.grey[400],
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor ?? Colors.grey,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, bool isExpiringSoon) {
    if (!isExpired && !isExpiringSoon) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpired ? Colors.red : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: isExpired ? Colors.red : Colors.orange,
          ),
          SizedBox(width: 8),
          Text(
            isExpired ? 'Expired' : 'Expiring Soon',
            style: TextStyle(
              color: isExpired ? Colors.red : Colors.orange,
              fontWeight: FontWeight.w600,
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
        title: Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete ${product.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
