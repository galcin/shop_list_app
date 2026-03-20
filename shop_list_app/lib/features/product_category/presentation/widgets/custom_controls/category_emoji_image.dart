// category_emoji_image.dart  –  analogous to movie_image.dart
import 'package:flutter/material.dart';

/// A circular avatar that shows a category image asset when available,
/// falling back to the category emoji when no image is set.
/// Positioned on the left side, overlaid on top of [CategoryCard],
/// mirroring the `MovieImage` overlay pattern from movies_ui.
class CategoryEmojiImage extends StatelessWidget {
  final String emoji;
  final Color accentColor;

  /// Optional asset image filename (e.g. 'fruits_category.png').
  /// When provided, renders the image instead of the emoji.
  final String? imageName;

  const CategoryEmojiImage({
    super.key,
    required this.emoji,
    required this.accentColor,
    this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withOpacity(0.35),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: imageName != null
            ? Image.asset(
                'assets/images/$imageName',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              )
            : Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
      ),
    );
  }
}
