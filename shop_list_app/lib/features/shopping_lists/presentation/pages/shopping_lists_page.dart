import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/create_list_dialog.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/widgets/shopping_list_card.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';

class ShoppingListsPage extends ConsumerWidget {
  const ShoppingListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);

    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          'Shopping Lists',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colors.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: listsAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, __) => Center(
          child: Text(
            e.toString(),
            style: TextStyle(
                fontFamily: 'Poppins', color: colors.onSurfaceVariant),
          ),
        ),
        data: (lists) {
          if (lists.isEmpty) {
            return _EmptyState(
                onCreateTap: () => _showCreateDialog(context, ref));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length + 1, // +1 for "New list" card at bottom
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == lists.length) {
                return _NewListCard(
                    onTap: () => _showCreateDialog(context, ref));
              }
              return ShoppingListCard(
                list: lists[index],
                onTap: () => context.go('/shopping/${lists[index].id}'),
                onLongPress: () => _showContextMenu(context, ref, lists[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateListDialog(),
    );
    if (name == null || !context.mounted) return;
    final result =
        await ref.read(shoppingListsProvider.notifier).createList(name);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {},
    );
  }

  void _showContextMenu(
      BuildContext context, WidgetRef ref, ShoppingListEntity list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ListContextMenu(list: list),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No lists yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first shopping list\nto get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add),
            label: const Text(
              'Create your first list',
              style:
                  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewListCard extends StatelessWidget {
  const _NewListCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        strokeColor: colors.outline,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'New list',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple dashed-border container (no external dependency).
class DottedBorder extends StatelessWidget {
  const DottedBorder(
      {super.key, required this.child, required this.strokeColor});

  final Widget child;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashBorderPainter(strokeColor),
      child: child,
    );
  }
}

class _DashBorderPainter extends CustomPainter {
  _DashBorderPainter(this.strokeColor);

  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final radius = Radius.circular(12);
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), radius);
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ListContextMenu extends ConsumerWidget {
  const _ListContextMenu({required this.list});

  final ShoppingListEntity list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text('Rename',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => CreateListDialog(initialName: list.name),
                );
                if (name == null || !context.mounted) return;
                final result = await ref
                    .read(shoppingListsProvider.notifier)
                    .renameList(list, name);
                if (!context.mounted) return;
                result.fold(
                  (f) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message))),
                  (_) {},
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              title: const Text('Delete',
                  style: TextStyle(
                      color: Color(0xFFEF4444), fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                final totalItems = list.items.length;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Delete list?',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins')),
                    content: Text(
                      totalItems > 0
                          ? 'This will delete "${list.name}" and its $totalItems item${totalItems == 1 ? '' : 's'}.'
                          : 'Delete "${list.name}"?',
                      style: const TextStyle(
                          color: Colors.white70, fontFamily: 'Poppins'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                final result = await ref
                    .read(shoppingListsProvider.notifier)
                    .deleteList(list.id!);
                if (!context.mounted) return;
                result.fold(
                  (f) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message))),
                  (_) {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
