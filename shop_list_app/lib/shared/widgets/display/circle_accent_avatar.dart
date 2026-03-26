import 'package:flutter/material.dart';

/// A generic circular container with an accent-coloured border and shadow.
///
/// Accepts any [child] widget to display inside the circle.
/// Used by [CategoryEmojiImage] and product image overlays to provide
/// a consistent circular avatar style across the app.
class CircleAccentAvatar extends StatelessWidget {
  const CircleAccentAvatar({
    required this.child,
    required this.accentColor,
    this.size = 84,
    this.borderWidth = 2.2,
    this.backgroundOpacity = 0.12,
    this.borderOpacity = 0.35,
    this.shadowOpacity = 0.18,
    this.shadowBlurRadius = 10,
    this.shadowOffset = const Offset(0, 3),
    super.key,
  });

  /// The widget to display inside the circle (e.g. image, emoji text, icon).
  final Widget child;

  /// The accent colour used for the background tint, border, and shadow.
  final Color accentColor;

  /// Diameter of the circle in logical pixels.
  final double size;

  /// Width of the accent-coloured border.
  final double borderWidth;

  /// Opacity of the accent-coloured background fill.
  final double backgroundOpacity;

  /// Opacity of the accent-coloured border.
  final double borderOpacity;

  /// Opacity of the drop shadow.
  final double shadowOpacity;

  /// Blur radius of the drop shadow.
  final double shadowBlurRadius;

  /// Offset of the drop shadow.
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(backgroundOpacity),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withOpacity(borderOpacity),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(shadowOpacity),
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }
}
