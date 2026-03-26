import 'package:flutter/material.dart';

/// A generic wrapper around [ReorderableListView.builder].
///
/// [itemBuilder] receives the build context, the item's current index, and
/// the item itself.  The widget returned **must** carry a [Key] — typically
/// `ValueKey(item.id)` — as required by [ReorderableListView].
///
/// [onReorder] fires with raw old/new indices; any index adjustment (e.g.
/// `if (newIndex > oldIndex) newIndex--`) should be performed inside the
/// callback.
class AppReorderableListView<T> extends StatelessWidget {
  const AppReorderableListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<T> items;

  /// Builder that must return a widget with a unique [Key].
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  final void Function(int oldIndex, int newIndex) onReorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      //padding: padding,
      itemCount: items.length,
      onReorder: onReorder,
      itemBuilder: (ctx, i) => itemBuilder(ctx, i, items[i]),
    );
  }
}
