import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';

/// What the user picked in [showShoppingListPickerSheet]: either an existing
/// list ([listId]) or the name of a list to create ([newListName]).
class ShoppingListTarget {
  const ShoppingListTarget.existing(this.listId) : newListName = null;
  const ShoppingListTarget.create(this.newListName) : listId = null;

  final int? listId;
  final String? newListName;
}

/// Bottom sheet that lets the user choose which shopping list to add items
/// to, or type the name of a new one.
Future<ShoppingListTarget?> showShoppingListPickerSheet(
  BuildContext context, {
  String title = 'Add to shopping list',
  String defaultNewListName = '',
}) {
  return showModalBottomSheet<ShoppingListTarget>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ShoppingListPickerSheet(
      title: title,
      defaultNewListName: defaultNewListName,
    ),
  );
}

class _ShoppingListPickerSheet extends ConsumerStatefulWidget {
  const _ShoppingListPickerSheet({
    required this.title,
    required this.defaultNewListName,
  });

  final String title;
  final String defaultNewListName;

  @override
  ConsumerState<_ShoppingListPickerSheet> createState() =>
      _ShoppingListPickerSheetState();
}

class _ShoppingListPickerSheetState
    extends ConsumerState<_ShoppingListPickerSheet> {
  late final TextEditingController _nameCtrl;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.defaultNewListName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submitNew() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(ShoppingListTarget.create(name));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final listsAsync = ref.watch(shoppingListsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          if (!_creating) ...[
            listsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                'Could not load lists',
                style: TextStyle(fontFamily: 'Poppins', color: colors.error),
              ),
              data: (lists) {
                if (lists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'You have no shopping lists yet.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: lists.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final list = lists[i];
                      final listId = list.id;
                      final open = list.items.length - list.checkedCount;
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.shopping_cart_outlined,
                              color: colors.primary, size: 20),
                        ),
                        title: Text(
                          list.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '$open open item${open == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right,
                            color: colors.onSurfaceVariant),
                        onTap: listId == null
                            ? null
                            : () => Navigator.of(context)
                                .pop(ShoppingListTarget.existing(listId)),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _creating = true),
              icon: Icon(Icons.add, color: colors.primary),
              label: Text(
                'New list',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submitNew(),
              style: TextStyle(fontFamily: 'Poppins', color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                    fontFamily: 'Poppins', color: colors.onSurfaceVariant),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _creating = false),
                  child: Text('Back',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: colors.onSurfaceVariant)),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _submitNew,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Create & add',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
