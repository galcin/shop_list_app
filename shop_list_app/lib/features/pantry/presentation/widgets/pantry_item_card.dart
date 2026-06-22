import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';

class PantryItemCard extends ConsumerStatefulWidget {
  final PantryItem item;

  const PantryItemCard({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends ConsumerState<PantryItemCard> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final opacity = widget.item.isOutOfStock ? 0.5 : 1.0;

    return Dismissible(
      key: Key('pantry-${widget.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDelete();
      },
      onDismissed: (_) async {
        await _deleteItem();
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  _buildExpiryIndicator(context),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.item.quantity.toString()} ${widget.item.unit}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[300],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.expiryDate != null) ...[
                          Text(
                            'Exp: ${_formatDate(widget.item.expiryDate!)} (${widget.item.daysUntilExpiry ?? 0} days)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                        ] else ...[
                          Text(
                            'No expiry date',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildQuantityStepper(context),
                ],
              ),
              if (widget.item.isOutOfStock)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Out of stock',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryIndicator(BuildContext context) {
    Color indicatorColor;
    String tooltip;

    switch (widget.item.expiryStatus) {
      case 'expired':
        indicatorColor = Colors.red;
        tooltip = 'Expired';
        break;
      case 'expiring-soon':
        indicatorColor = Colors.amber;
        tooltip = 'Expiring soon';
        break;
      case 'fresh':
        indicatorColor = Colors.green;
        tooltip = 'Fresh';
        break;
      default:
        indicatorColor = Colors.grey;
        tooltip = 'No expiry date';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: indicatorColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _isDeleting ? null : _decreaseQuantity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.remove,
                size: 18,
                color: _isDeleting ? Colors.grey : Colors.white70,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.item.quantity.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          InkWell(
            onTap: _isDeleting ? null : _increaseQuantity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.add,
                size: 18,
                color: _isDeleting ? Colors.grey : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _increaseQuantity() async {
    await ref.read(pantryItemsProvider.notifier).updateQuantity(
          widget.item.id!,
          widget.item.quantity + 1,
        );
  }

  Future<void> _decreaseQuantity() async {
    if (widget.item.quantity > 0) {
      await ref.read(pantryItemsProvider.notifier).updateQuantity(
            widget.item.id!,
            widget.item.quantity - 1,
          );
    }
  }

  Future<bool> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "${widget.item.name}" from pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<void> _deleteItem() async {
    setState(() => _isDeleting = true);
    try {
      await ref.read(pantryItemsProvider.notifier).deleteItem(widget.item.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${widget.item.name}"'),
            backgroundColor: Colors.green[400],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove item'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
