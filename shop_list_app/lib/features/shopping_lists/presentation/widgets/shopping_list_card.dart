import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final totalItems = list.items.length;
    final checkedItems = list.checkedCount;
    final progress = list.completionPercent;
    final dateStr = DateFormat('MMM d').format(list.createdAt);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$checkedItems/$totalItems done',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
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
                backgroundColor: colors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(colors.primary),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            // Meta row
            Row(
              children: [
                Text(
                  '$totalItems item${totalItems == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (totalItems > 0) ...[
                  Text(' • ',
                      style: TextStyle(
                          color: colors.onSurfaceVariant, fontSize: 12)),
                  Text(
                    'Created $dateStr',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
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
