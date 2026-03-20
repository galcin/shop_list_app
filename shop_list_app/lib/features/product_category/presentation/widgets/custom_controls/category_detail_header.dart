// category_detail_header.dart  –  analogous to movie_detail_header.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';

/// Text block showing the category name, ID and accent colour chip.
/// Intended to sit beside the mini emoji in [CategoryDetailHeaderPoster],
/// mirroring `MovieDetailHeader`.
class CategoryDetailHeader extends StatelessWidget {
  final ProductCategory category;
  final Color accentColor;

  const CategoryDetailHeader({
    super.key,
    required this.category,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year / Genre equivalent → sort order tag
        Text(
          'Sort order ${category.sortOrder}'.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        // Title equivalent
        Text(
          category.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Plot equivalent → ID
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: 'Category #${category.id}'),
              if (category.colorHex != null) ...[
                const TextSpan(text: '  ·  '),
                TextSpan(
                  text: category.colorHex,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
