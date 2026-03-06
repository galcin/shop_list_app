import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';

/// A dismissible grid/list card that shows an emoji icon and a title.
///
/// Swiping left-to-right reveals a delete background. The [confirmDismiss]
/// callback is called before the item is removed; [onDismissed] is called
/// after the item has been removed from the tree.
class DismissibleEmojiCard extends StatelessWidget {
  const DismissibleEmojiCard({
    super.key,
    required this.itemKey,
    required this.accentColor,
    required this.emoji,
    required this.title,
    required this.onTap,
    this.onLongPress,
    required this.confirmDismiss,
    required this.onDismissed,
  });

  /// Unique key used by [Dismissible].
  final Key itemKey;

  /// Background / accent colour for the card border and fill tint.
  final Color accentColor;

  /// Emoji (or any short string) shown as the card's main icon.
  final String emoji;

  final String title;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Future<bool?> Function(DismissDirection) confirmDismiss;
  final void Function(DismissDirection) onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
