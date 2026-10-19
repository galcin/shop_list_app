import 'package:flutter/material.dart';
import 'package:shop_list_app/features/recipes/domain/entities/recipe.dart';

/// Renders a recipe picture from an asset path or URL and falls back to a
/// generated, category-coloured placeholder when the recipe has no image.
///
/// The placeholder is drawn with widgets, so recipes shipped without a photo
/// cost no asset bytes; swapping in a real image later only requires setting
/// `imageUrl`.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheSize,
    this.iconSize,
  });

  final Recipe recipe;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Decoded image size cap (both axes) to keep memory in check in lists.
  final int? cacheSize;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final url = recipe.imageUrl;
    if (url == null || url.isEmpty) return _placeholder(context);

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final style = RecipeCategoryStyle.of(recipe.category);
    final size = iconSize ??
        ((height ?? width ?? 96) * 0.4).clamp(20.0, 72.0).toDouble();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.color.withValues(alpha: 0.95), style.darkColor],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, size: size, color: Colors.white.withValues(alpha: 0.9)),
    );
  }
}

/// Icon and colour used to represent a recipe category when no photo exists.
class RecipeCategoryStyle {
  const RecipeCategoryStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  Color get darkColor => HSLColor.fromColor(color)
      .withLightness(
          (HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0))
      .toColor();

  static const Map<String, RecipeCategoryStyle> _styles = {
    'breakfast': RecipeCategoryStyle(Icons.egg_alt_outlined, Color(0xFFF2A541)),
    'soups': RecipeCategoryStyle(Icons.soup_kitchen_outlined, Color(0xFFE0714F)),
    'salads': RecipeCategoryStyle(Icons.eco_outlined, Color(0xFF6DB36B)),
    'main courses': RecipeCategoryStyle(Icons.restaurant_outlined, Color(0xFFC75146)),
    'pasta & rice': RecipeCategoryStyle(Icons.ramen_dining_outlined, Color(0xFFD9A441)),
    'side dishes': RecipeCategoryStyle(Icons.rice_bowl_outlined, Color(0xFF8E9B5B)),
    'desserts': RecipeCategoryStyle(Icons.cake_outlined, Color(0xFFC86B98)),
    'snacks & appetizers': RecipeCategoryStyle(Icons.cookie_outlined, Color(0xFFB8864B)),
    'snacks': RecipeCategoryStyle(Icons.cookie_outlined, Color(0xFFB8864B)),
    'drinks': RecipeCategoryStyle(Icons.local_cafe_outlined, Color(0xFF5B8DB8)),
    'sauces & dips': RecipeCategoryStyle(Icons.soup_kitchen, Color(0xFF9C7A4B)),
    'baking': RecipeCategoryStyle(Icons.bakery_dining_outlined, Color(0xFFB57F50)),
  };

  static const RecipeCategoryStyle _fallback =
      RecipeCategoryStyle(Icons.restaurant_menu, Color(0xFF7E8A97));

  static RecipeCategoryStyle of(String? category) {
    if (category == null) return _fallback;
    return _styles[category.trim().toLowerCase()] ?? _fallback;
  }
}
