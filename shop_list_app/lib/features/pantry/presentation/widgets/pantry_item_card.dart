import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/presentation/widgets/product_image_widget.dart';
import 'package:shop_list_app/shared/widgets/display/circle_accent_avatar.dart';
import 'package:shop_list_app/shared/widgets/list/accent_circle_list_card.dart';

class PantryItemCard extends ConsumerStatefulWidget {
  final PantryItem item;

  const PantryItemCard({super.key, required this.item});

  @override
  ConsumerState<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends ConsumerState<PantryItemCard> {
  bool _isDeleting = false;

  // -- Helpers ----------------------------------------------------------------

  Color _accentColor(ProductCategory? cat) {
    final hex = cat?.colorHex;
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Widget _circleIcon(ProductCategory? cat, Color accent) {
    if (cat?.imageName != null) {
      return ClipOval(
        child: Image.asset(
          'assets/images/${cat!.imageName}',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _emojiOrDefault(cat.iconName, accent),
        ),
      );
    }
    return _emojiOrDefault(cat?.iconName, accent);
  }

  Widget _emojiOrDefault(String? emoji, Color accent) {
    if (emoji != null && emoji.isNotEmpty) {
      return Center(child: Text(emoji, style: const TextStyle(fontSize: 30)));
    }
    return Icon(Icons.kitchen_outlined, color: accent, size: 30);
  }

  String _formatQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();

  String _formatDate(DateTime date) =>
      '${date.month.toString().padLeft(2, "0")}/${date.day.toString().padLeft(2, "0")}';

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4), width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );

  Widget _buildQuantityStepper(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _isDeleting ? null : _decreaseQuantity,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.remove,
                    size: 16,
                    color: _isDeleting
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                _formatQty(widget.item.quantity),
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            InkWell(
              onTap: _isDeleting ? null : _increaseQuantity,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.add,
                    size: 16,
                    color: _isDeleting
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      );

  // -- Build ------------------------------------------------------------------

  /// Returns the avatar child: product photo/emoji when the item is linked to
  /// a product and that product has a photo, otherwise the category icon.
  Widget _buildAvatarChild(
      String? productPhoto, ProductCategory? cat, Color accent) {
    if (productPhoto != null && productPhoto.isNotEmpty) {
      return ProductImageWidget(
        photo: productPhoto,
        size: 52,
        borderRadius: 26,
        backgroundColor: Colors.transparent,
      );
    }
    return _circleIcon(cat, accent);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(productCategoryListProvider).asData?.value ?? [];
    final cat = categories.cast<ProductCategory?>().firstWhere(
          (c) => c?.id == widget.item.categoryId,
          orElse: () => null,
        );
    final accent = _accentColor(cat);

    // Look up the linked product's photo (if any)
    final products = ref.watch(productListProvider).asData?.value ?? [];
    String? productPhoto;
    if (widget.item.productId != null) {
      for (final product in products) {
        if (product.id == widget.item.productId) {
          productPhoto = product.photo;
          break;
        }
      }
    }

    return Dismissible(
      key: Key('pantry-${widget.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(left: 56, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => _deleteItem(),
      child: AccentCircleListCard(
        accentColor: accent,
        circleChild: CircleAccentAvatar(
          accentColor: accent,
          size: 96,
          child: _buildAvatarChild(productPhoto, cat, accent),
        ),
        child: Opacity(
          opacity: widget.item.isOutOfStock ? 0.5 : 1.0,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  widget.item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: accent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              cat?.name ?? 'Pantry',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatQty(widget.item.quantity)} ${widget.item.unit}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.item.isOutOfStock)
                      _badge('Out of stock', Colors.grey)
                    else if (widget.item.isExpired)
                      _badge('Expired', Theme.of(context).colorScheme.error)
                    else if ((widget.item.daysUntilExpiry ?? 99) < 3)
                      _badge('Exp. ${_formatDate(widget.item.expiryDate!)}',
                          Theme.of(context).colorScheme.primary)
                    else
                      _buildQuantityStepper(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Actions ----------------------------------------------------------------

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
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Item',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove "${widget.item.name}" from pantry?',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
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
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed "${widget.item.name}"',
              style: TextStyle(color: theme.colorScheme.onInverseSurface),
            ),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}
