import 'package:flutter/material.dart';
import 'package:shop_list_app/shared/widgets/add_item_tile.dart';

/// A generic two-column (configurable) grid view.
///
/// When [onAddTap] is provided an [AddItemTile] is appended as the last cell,
/// allowing users to create new items directly from the grid.
class AppGridView<T> extends StatelessWidget {
  const AppGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onAddTap,
    this.addLabel = 'New Item',
    this.padding = const EdgeInsets.fromLTRB(8, 12, 8, 100),
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 12.0,
    this.childAspectRatio = 0.95,
  });

  final List<T> items;

  /// Called for each item in [items].
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// When non-null an [AddItemTile] is rendered as the last grid cell.
  final VoidCallback? onAddTap;

  /// Label shown inside the [AddItemTile].
  final String addLabel;

  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final hasAddTile = onAddTap != null;
    final itemCount = items.length + (hasAddTile ? 1 : 0);

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        if (hasAddTile && i == items.length) {
          return AddItemTile(onTap: onAddTap!, label: addLabel);
        }
        return itemBuilder(ctx, items[i]);
      },
    );
  }
}
