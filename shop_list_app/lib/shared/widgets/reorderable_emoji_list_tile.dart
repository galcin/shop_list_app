import 'package:flutter/material.dart';
import 'package:shop_list_app/core/theme/colors.dart';

/// A list tile designed for use inside a [ReorderableListView].
///
/// Displays an emoji badge on the left and a drag handle on the right.
/// The [index] must match the item's position in the list so that
/// [ReorderableDragStartListener] works correctly.
class ReorderableEmojiListTile extends StatelessWidget {
  const ReorderableEmojiListTile({
    super.key,
    required this.index,
    required this.accentColor,
    required this.emoji,
    required this.title,
  });

  /// Position of this tile in the list — passed to [ReorderableDragStartListener].
  final int index;

  /// Colour used for the left badge background and card border.
  final Color accentColor;

  /// Emoji (or short string) rendered inside the left badge.
  final String emoji;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
