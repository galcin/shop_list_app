import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart';
import 'package:shop_list_app/presentation/providers/shopping/product_category_providers.dart';

// ── Colour & icon presets ─────────────────────────────────────────────────────

const _kSwatches = [
  Color(0xFF53B175), // primary green
  Color(0xFF2196F3), // blue
  Color(0xFFF8A44C), // amber / accent
  Color(0xFFE91E63), // pink
  Color(0xFF9C27B0), // purple
  Color(0xFFF3603F), // orange-red (error)
];

const _kIcons = ['🥛', '🥬', '🥩', '🧂', '🍞', '🧴', '🍎', '🧁', '🥚', '🧃'];

// ── Public helpers ────────────────────────────────────────────────────────────

/// Shows the **Create Category** bottom sheet.
Future<void> showCreateCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CategorySheet(),
  );
}

/// Shows the **Edit Category** bottom sheet pre-filled with [category] data.
Future<void> showEditCategorySheet(
    BuildContext context, ProductCategory category) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategorySheet(existing: category),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({this.existing});

  final ProductCategory? existing;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late final TextEditingController _nameCtrl;
  String? _selectedColorHex;
  String? _selectedIcon;
  String? _nameError;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _selectedColorHex = e?.colorHex;
    _selectedIcon = e?.iconName ?? e?.photo;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Category name is required.');
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });

    final notifier = ref.read(productCategoryListProvider.notifier);

    final result = _isEditing
        ? await notifier.updateCategory(
            id: widget.existing!.id,
            name: name,
            colorHex: _selectedColorHex,
            iconName: _selectedIcon,
            sortOrder: widget.existing!.sortOrder,
          )
        : await notifier.createCategory(
            name: name,
            colorHex: _selectedColorHex,
            iconName: _selectedIcon,
          );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            _isEditing ? 'Edit Category' : 'New Category',
            style: const TextStyle(
              color: Color(0xFF181725),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          // Name field
          TextField(
            controller: _nameCtrl,
            autofocus: !_isEditing,
            style: const TextStyle(
              color: Color(0xFF181725),
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Category name *  e.g. "Dairy"',
              hintStyle: const TextStyle(
                color: Color(0xFF7C7C7C),
                fontFamily: 'Poppins',
              ),
              filled: true,
              fillColor: const Color(0xFFF2F3F2),
              errorText: _nameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFF53B175), width: 1.5),
              ),
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 20),
          // Colour swatches
          const Text(
            'Colour',
            style: TextStyle(
              color: Color(0xFF7C7C7C),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _kSwatches.map((color) {
              final hex =
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
              final selected = _selectedColorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorHex = hex),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: const Color(0xFF53B175), width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Emoji / icon picker
          const Text(
            'Icon',
            style: TextStyle(
              color: Color(0xFF7C7C7C),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kIcons.map((emoji) {
              final selected = _selectedIcon == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = emoji),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF53B175).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(color: const Color(0xFF53B175), width: 2)
                        : null,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53B175),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEditing ? 'Save Changes' : '+ Create Category',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
