// category_product_tile.dart  –  analogous to movie_field.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';

/// A single product row inside the detail page's products list.
/// Mirrors the role of `MovieField` – a small, self-contained display widget.
class CategoryProductTile extends StatelessWidget {
  final Product product;

  const CategoryProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji / placeholder icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: product.photo != null && product.photo!.isNotEmpty
                  ? Text(product.photo!, style: const TextStyle(fontSize: 24))
                  : const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.border,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Unnamed product',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${product.quantity ?? 0} ${product.units ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Optional expiration badge
          if (product.expirationDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(product.expirationDate!),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
