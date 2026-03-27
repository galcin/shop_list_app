import 'package:flutter/material.dart';
import 'package:shop_list_app/features/products/presentation/widgets/product_image_widget.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';

/// A single item row in the shopping list detail view.
/// Supports animated checkbox and swipe-to-delete (handled externally via [Dismissible]).
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    this.productPhoto,
  });

  final ShoppingItemEntity item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String? productPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                item.isChecked
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color:
                    item.isChecked ? colors.primary : colors.onSurfaceVariant,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            if (productPhoto != null)
              ProductImageWidget(
                photo: productPhoto,
                size: 46,
                borderRadius: 12,
                backgroundColor: colors.surfaceVariant,
              )
            else
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.onSurfaceVariant,
                  size: 22,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: item.isChecked
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatQty(item.quantity)} ${item.unit}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: item.isChecked
                          ? colors.onSurfaceVariant.withOpacity(0.75)
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isChecked)
              Icon(Icons.drag_handle, color: colors.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }
}
