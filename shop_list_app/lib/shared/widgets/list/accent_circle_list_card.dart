import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';

/// A reusable list card that uses the Stack pattern:
/// a circular avatar overlapping the left edge of a card body.
///
/// The circle (size = [height]) is positioned flush at top-left.
/// The card body is offset to the right so both elements overlap cleanly
/// — no left border is drawn on the card.
///
/// Usage:
/// ```dart
/// AccentCircleListCard(
///   accentColor: accentColor,
///   circleChild: CircleAccentAvatar(
///     accentColor: accentColor,
///     size: 96,
///     child: ProductImageWidget(...),
///   ),
///   onTap: () {},
///   onLongPress: () {},
///   child: _MyCardContent(),
/// )
/// ```
class AccentCircleListCard extends StatelessWidget {
  const AccentCircleListCard({
    super.key,
    required this.accentColor,
    required this.circleChild,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.height = 96.0,
    this.borderRadius = 18.0,
    this.circleLeftOffset = 56.0,
  });

  /// Accent colour used for the card body's border.
  final Color accentColor;

  /// Widget shown as the circular left overlay (e.g. [CircleAccentAvatar]).
  final Widget circleChild;

  /// Content rendered inside the card body.
  final Widget child;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Height of both the card and the circle.
  final double height;

  /// Corner radius applied to the top-right / bottom-right of the card.
  final double borderRadius;

  /// How far the card body is pushed to the right so the circle overlaps it.
  final double circleLeftOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Card body (offset right) ─────────────────────────────────
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            width: double.infinity,
            height: height,
            margin: EdgeInsets.only(left: circleLeftOffset, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              // No left border - the circle covers that edge cleanly.
              border: const Border(
                top: BorderSide(color: AppColors.divider, width: 0.8),
                right: BorderSide(color: AppColors.divider, width: 0.8),
                bottom: BorderSide(color: AppColors.divider, width: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: child,
          ),
        ),
        // ── Circular overlay (flush top-left) ────────────────────────
        Positioned(
          top: 0,
          left: 0,
          child: circleChild,
        ),
      ],
    );
  }
}
