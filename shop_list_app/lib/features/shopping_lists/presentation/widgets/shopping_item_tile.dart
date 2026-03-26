import 'package:flutter/material.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';

/// A single item row in the shopping list detail view.
/// Supports animated checkbox and swipe-to-delete (handled externally via [Dismissible]).
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingItemEntity item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const _cardColor = Color(0xFF1E1E1E);
  static const _checkedColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: item.isChecked
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFF6B35),
                      key: ValueKey('checked'),
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white54,
                      key: ValueKey('unchecked'),
                    ),
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: item.isChecked ? _checkedColor : Colors.white,
              decoration: item.isChecked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: _checkedColor,
            ),
          ),
          subtitle: Text(
            '${_formatQty(item.quantity)} ${item.unit}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: item.isChecked
                  ? _checkedColor.withOpacity(0.7)
                  : Colors.white54,
            ),
          ),
          trailing: item.isChecked
              ? null
              : const Icon(Icons.drag_handle, color: Colors.white38, size: 18),
        ),
      ),
    );
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }
}
