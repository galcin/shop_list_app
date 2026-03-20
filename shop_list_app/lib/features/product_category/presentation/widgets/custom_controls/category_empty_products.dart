// category_empty_products.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';

/// Empty-state shown inside [CategoryProductsSection] when a category has
/// no products yet.
class CategoryEmptyProducts extends StatelessWidget {
  const CategoryEmptyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No products in this category',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
