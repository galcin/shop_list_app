// category_detail_thumbnail.dart  –  analogous to movie_detail_thumbnail.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';

/// Full-width banner shown at the top of the detail page.
/// When the category has an [imageName] the image is shown inside the
/// floating card; otherwise the emoji is used – mirroring the
/// `MovieDetailThumbnail` composition.
class CategoryDetailThumbnail extends StatelessWidget {
  final ProductCategory category;
  final Color accentColor;

  const CategoryDetailThumbnail({
    super.key,
    required this.category,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = category.iconName ?? category.photo ?? '?';
    final imageName = category.imageName;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // ── Background band ──────────────────────────────────────────────
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: accentColor.withOpacity(0.07),
            ),
            // Floating image/emoji card
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: imageName != null
                    ? Image.asset(
                        'assets/images/$imageName',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
              ),
            ),
          ],
        ),
        // ── Bottom gradient fade (same gradient trick as MovieDetailThumbnail) ──
        Container(
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00FCFCFC), Color(0xFFFCFCFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
