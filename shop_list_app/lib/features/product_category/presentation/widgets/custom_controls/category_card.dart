// category_card.dart  –  analogous to movie_card.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';

/// The "body" card for a category list row.
/// It is intentionally offset to the right so that [CategoryEmojiImage]
/// can be placed on top of it (Stack / Positioned pattern from movies_ui).
class CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.accentColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: MediaQuery.of(context).size.width,
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
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                category.name,
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
                  // Accent colour dot + hex label
                  Row(
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
                      Text(
                        category.colorHex ?? 'default',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
