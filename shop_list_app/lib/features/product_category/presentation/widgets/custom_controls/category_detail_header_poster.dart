// category_detail_header_poster.dart  –  analogous to movie_detail_header_poster.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/widgets/custom_controls/category_detail_header.dart';

/// A row that combines a small image/emoji "poster" on the left with the text
/// block [CategoryDetailHeader] on the right – mirroring `MovieDetailHeaderPoster`.
class CategoryDetailHeaderPoster extends StatelessWidget {
  final ProductCategory category;
  final Color accentColor;

  const CategoryDetailHeaderPoster({
    super.key,
    required this.category,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = category.iconName ?? category.photo ?? '?';
    final imageName = category.imageName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini image/emoji "poster"
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: imageName != null
                  ? Image.asset(
                      'assets/images/$imageName',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 36)),
                      ),
                    )
                  : Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 36)),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CategoryDetailHeader(
              category: category,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
