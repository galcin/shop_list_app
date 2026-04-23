// category_emoji_image.dart
import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';

/// A circular avatar that shows a category image asset when available,
/// falling back to the category emoji when no image is set.
/// Positioned on the left side, overlaid on top of [CategoryCard].
/// Uses [CircleAccentAvatar] for the consistent circular ring style.
class CategoryEmojiImage extends StatelessWidget {
  final String emoji;
  final Color accentColor;

  /// Optional asset image filename (e.g. 'fruits_category.png').
  /// When provided, renders the image instead of the emoji.
  final String? imageName;

  final double size;

  const CategoryEmojiImage({
    super.key,
    required this.emoji,
    required this.accentColor,
    this.imageName,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAccentAvatar(
      accentColor: accentColor,
      size: size,
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
    );
  }
}
