import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';

/// Card showing list name, item count, completion bar, and creation date.
/// Long-press triggers the [onLongPress] callback (rename / delete menu).
class ShoppingListCard extends StatelessWidget {
  const ShoppingListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onLongPress,
  });

  final ShoppingListEntity list;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const _cardColor = Color(0xFF1E1E1E);
  static const _progressFilled = Color(0xFFFF6B35);
  static const _progressTrack = Color(0xFF2A2A2A);
  static const _textSecondary = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final totalItems = list.items.length;
    final checkedItems = list.checkedCount;
    final progress = list.completionPercent;
    final dateStr = DateFormat('MMM d').format(list.createdAt);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🛒', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    list.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$checkedItems/$totalItems done',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _progressTrack,
                valueColor: const AlwaysStoppedAnimation(_progressFilled),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            // Meta row
            Row(
              children: [
                Text(
                  '$totalItems item${totalItems == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
                if (totalItems > 0) ...[
                  const Text(' • ',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                  Text(
                    'Created $dateStr',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
