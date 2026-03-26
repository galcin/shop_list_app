// create_product_bottom_sheet.dart
//
// Reusable bottom sheet for creating and editing products.
// Supports:
//   • Picking a real photo from camera or gallery (image_picker)
//   • Choosing an emoji/icon from a curated preset grid
//   • Falling back to a default icon when no photo is provided
//
// Public API:
//   showCreateProductSheet(context, {initialCategoryId})  – create flow
//   showEditProductSheet(context, product)                – edit flow
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';

// ── Presets ────────────────────────────────────────────────────────────────────

const _kProductEmojis = [
  '🥛',
  '🧀',
  '🥚',
  '🍖',
  '🥩',
  '🍗',
  '🥦',
  '🥬',
  '🥕',
  '🍎',
  '🍌',
  '🍋',
  '🥖',
  '🍞',
  '🧁',
  '🍰',
  '🍫',
  '🍬',
  '☕',
  '🍵',
  '🧃',
  '🥤',
  '🍺',
  '🍷',
  '🧴',
  '🧼',
  '🪥',
  '🧹',
  '🧺',
  '🛁',
  '🐟',
  '🍣',
  '🥫',
  '🌽',
  '🧅',
  '🧄',
];

const _kUnits = [
  'pcs',
  'kg',
  'g',
  'L',
  'mL',
  'pack',
  'bottle',
  'box',
  'bag',
  'can',
];

// ── Public helpers ─────────────────────────────────────────────────────────────

/// Shows the **Create Product** bottom sheet.
/// Pass [initialCategoryId] to pre-select a category (e.g. opened from the
/// category detail page).
Future<void> showCreateProductSheet(
  BuildContext context, {
  int? initialCategoryId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductSheet(initialCategoryId: initialCategoryId),
  );
}

/// Shows the **Edit Product** bottom sheet pre-filled with [product] data.
Future<void> showEditProductSheet(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductSheet(existing: product),
  );
}

// ── Sheet widget ───────────────────────────────────────────────────────────────

class _ProductSheet extends ConsumerStatefulWidget {
  const _ProductSheet({this.existing, this.initialCategoryId});

  final Product? existing;
  final int? initialCategoryId;

  @override
  ConsumerState<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends ConsumerState<_ProductSheet> {
  late final TextEditingController _nameCtrl;
  String _selectedUnit = 'pcs';
  int? _selectedCategoryId;

  /// Stores either:
  ///   – a local file path (starts with '/')
  ///   – an emoji string (e.g. '🥛')
  ///   – null / '' for no photo
  String? _photo;
  String? _nameError;
  bool _saving = false;
  bool _showEmojiPicker = false;

  bool get _isEditing => widget.existing != null;

  bool get _hasFilePhoto =>
      _photo != null &&
      _photo!.isNotEmpty &&
      (_photo!.startsWith('/') || _photo!.startsWith('file://'));

  bool get _hasEmoji => _photo != null && _photo!.isNotEmpty && !_hasFilePhoto;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _selectedUnit = (e?.units?.isNotEmpty == true) ? e!.units! : 'pcs';
    _selectedCategoryId = e?.productCategoryId ?? widget.initialCategoryId;
    _photo = (e?.photo?.isNotEmpty == true) ? e!.photo : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() {
        _photo = xfile.path;
        _showEmojiPicker = false;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Product name is required.');
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });

    final product = Product(
      id: _isEditing ? widget.existing!.id : 0,
      name: name,
      units: _selectedUnit,
      photo: _photo ?? '',
      productCategoryId: _selectedCategoryId,
      quantity: widget.existing?.quantity ?? 1.0,
      expirationDate: widget.existing?.expirationDate,
    );

    final notifier = ref.read(productListProvider.notifier);
    final result = _isEditing
        ? await notifier.updateProduct(product)
        : await notifier.addProduct(product);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        // Refresh category-scoped provider so the detail page updates too.
        if (_selectedCategoryId != null) {
          ref
              .read(categoryProductsProvider(_selectedCategoryId!).notifier)
              .refresh();
        }
        Navigator.of(context).pop(true); // return success signal
      },
    );
  }

  // ── Hint helper ──────────────────────────────────────────────────────────────

  /// Returns a category-specific example hint for the product name field.
  String _hintForCategory(List<ProductCategory> categories) {
    if (_selectedCategoryId == null) return 'Product name *  e.g. "Milk"';
    final match = categories.where((c) => c.id == _selectedCategoryId);
    if (match.isEmpty) return 'Product name *  e.g. "Milk"';
    final name = match.first.name.toLowerCase();
    const Map<String, String> _examples = {
      'fruit': 'e.g. "Granny Smith Apple"',
      'vegetable': 'e.g. "Baby Spinach"',
      'dairy': 'e.g. "Full-cream Milk"',
      'meat': 'e.g. "Chicken Breast"',
      'poultry': 'e.g. "Chicken Breast"',
      'seafood': 'e.g. "Atlantic Salmon"',
      'fish': 'e.g. "Atlantic Salmon"',
      'bakery': 'e.g. "Sourdough Bread"',
      'bread': 'e.g. "Sourdough Loaf"',
      'snack': 'e.g. "Salted Almonds"',
      'sweet': 'e.g. "Dark Chocolate"',
      'chocolate': 'e.g. "Dark Chocolate Bar"',
      'beverage': 'e.g. "Orange Juice"',
      'drink': 'e.g. "Sparkling Water"',
      'frozen': 'e.g. "Frozen Peas"',
      'cereal': 'e.g. "Rolled Oats"',
      'pasta': 'e.g. "Spaghetti 500g"',
      'grain': 'e.g. "Basmati Rice"',
      'rice': 'e.g. "Basmati Rice"',
      'sauce': 'e.g. "Tomato Pasta Sauce"',
      'condiment': 'e.g. "Dijon Mustard"',
      'spice': 'e.g. "Smoked Paprika"',
      'herb': 'e.g. "Fresh Basil"',
      'oil': 'e.g. "Olive Oil"',
      'cleaning': 'e.g. "Dish Soap"',
      'household': 'e.g. "Paper Towels"',
      'hygiene': 'e.g. "Hand Soap"',
      'personal': 'e.g. "Shampoo"',
      'baby': 'e.g. "Nappy Size 3"',
      'pet': 'e.g. "Dry Dog Food"',
    };
    for (final entry in _examples.entries) {
      if (name.contains(entry.key)) return 'Product name *  ${entry.value}';
    }
    // Fall back to capitalised category name as a generic hint.
    final catName = match.first.name;
    return 'Product name *  e.g. "$catName item"';
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(productCategoryListProvider).asData?.value ?? [];
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SingleChildScrollView(
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
                _isEditing ? 'Edit Product' : 'New Product',
                style: const TextStyle(
                  color: Color(0xFF181725),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              // Photo / icon section
              _buildPhotoSection(),
              if (_showEmojiPicker) ...[
                const SizedBox(height: 12),
                _buildEmojiPicker(),
              ],
              const SizedBox(height: 20),
              // Product name
              TextField(
                controller: _nameCtrl,
                autofocus: !_isEditing,
                style: const TextStyle(
                  color: Color(0xFF181725),
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: _hintForCategory(categories),
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFF3603F), width: 1.5),
                  ),
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),
              // Unit + Category row
              Row(
                children: [
                  Expanded(child: _buildUnitDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCategoryDropdown(categories)),
                ],
              ),
              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53B175),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF53B175).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(_isEditing ? 'Update Product' : '+ Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Photo section ─────────────────────────────────────────────────────────────

  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo preview – tapping opens the source picker
        GestureDetector(
          onTap: _showPhotoSourceSheet,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDBDBDB),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildPhotoPreview(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Photo / Icon',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181725),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _photoActionChip(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _photoActionChip(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _photoActionChip(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'Emoji',
                    onTap: () =>
                        setState(() => _showEmojiPicker = !_showEmojiPicker),
                    active: _showEmojiPicker || _hasEmoji,
                  ),
                ],
              ),
              if (_photo != null && _photo!.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() {
                    _photo = null;
                    _showEmojiPicker = false;
                  }),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 13, color: Color(0xFFF3603F)),
                      SizedBox(width: 3),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFFF3603F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    if (_photo == null || _photo!.isEmpty) {
      return const Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 36,
          color: Color(0xFFDBDBDB),
        ),
      );
    }
    if (_hasFilePhoto) {
      final file = File(_photo!.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 88,
          height: 88,
          errorBuilder: (_, __, ___) => _noPhotoIcon(),
        );
      }
    }
    // Emoji
    return Center(
      child: Text(_photo!, style: const TextStyle(fontSize: 40)),
    );
  }

  Widget _noPhotoIcon() {
    return const Center(
      child:
          Icon(Icons.broken_image_outlined, size: 36, color: Color(0xFFDBDBDB)),
    );
  }

  Widget _photoActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF53B175).withOpacity(0.12)
              : const Color(0xFFF2F3F2),
          borderRadius: BorderRadius.circular(10),
          border: active
              ? Border.all(color: const Color(0xFF53B175), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? const Color(0xFF53B175) : const Color(0xFF7C7C7C),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    active ? const Color(0xFF53B175) : const Color(0xFF7C7C7C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Emoji picker ──────────────────────────────────────────────────────────────

  Widget _buildEmojiPicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose an icon',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kProductEmojis.map((emoji) {
              final selected = _photo == emoji;
              return GestureDetector(
                onTap: () => setState(() {
                  _photo = emoji;
                  _showEmojiPicker = false;
                }),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF53B175).withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: selected
                        ? Border.all(color: const Color(0xFF53B175), width: 1.5)
                        : null,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Dropdowns ─────────────────────────────────────────────────────────────────

  Widget _buildUnitDropdown() {
    final units = [
      ..._kUnits,
      if (_selectedUnit.isNotEmpty && !_kUnits.contains(_selectedUnit))
        _selectedUnit,
    ];
    return DropdownButtonFormField<String>(
      value: units.contains(_selectedUnit) ? _selectedUnit : units.first,
      decoration: _dropdownDecoration('Default Unit'),
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF181725),
        fontSize: 14,
      ),
      dropdownColor: Colors.white,
      items:
          units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedUnit = v);
      },
    );
  }

  Widget _buildCategoryDropdown(List<ProductCategory> categories) {
    if (categories.isEmpty) {
      return TextField(
        enabled: false,
        decoration: _dropdownDecoration('Category').copyWith(
          hintText: 'No categories',
          hintStyle:
              const TextStyle(fontFamily: 'Poppins', color: Color(0xFF7C7C7C)),
        ),
      );
    }

    // Ensure selected value is valid
    final ids = categories.map((c) => c.id).toSet();
    if (_selectedCategoryId != null && !ids.contains(_selectedCategoryId)) {
      _selectedCategoryId = null;
    }
    _selectedCategoryId ??= categories.first.id;

    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: _dropdownDecoration('Category'),
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF181725),
        fontSize: 14,
      ),
      dropdownColor: Colors.white,
      isExpanded: true,
      items: categories.map((cat) {
        final emoji = cat.iconName ?? cat.photo ?? '';
        return DropdownMenuItem<int>(
          value: cat.id,
          child: Row(
            children: [
              if (emoji.isNotEmpty) ...[
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  cat.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedCategoryId = v);
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF7C7C7C),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF2F3F2),
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
        borderSide: const BorderSide(color: Color(0xFF53B175), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ── Photo source sheet ────────────────────────────────────────────────────────

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF53B175)),
              title: const Text('Take Photo',
                  style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF53B175)),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFF53B175)),
              title: const Text('Use Emoji Icon',
                  style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showEmojiPicker = true);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
