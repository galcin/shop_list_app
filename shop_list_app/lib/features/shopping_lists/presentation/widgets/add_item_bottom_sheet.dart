import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/shopping_lists/presentation/providers/shopping_list_providers.dart';

/// Bottom sheet for adding a new item to a list.
/// Shows a search/free-text field, quantity and unit inputs.
class AddItemBottomSheet extends ConsumerStatefulWidget {
  const AddItemBottomSheet({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<AddItemBottomSheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  String _unit = 'pcs';
  bool _isSubmitting = false;
  String _searchQuery = '';
  int? _selectedProductId;
  int? _selectedCategoryId;

  static const _units = ['pcs', 'kg', 'g', 'L', 'mL', 'oz', 'lb', 'cup'];
  static const _unitAliases = {
    'liter': 'L',
    'litre': 'L',
    'liters': 'L',
    'litres': 'L',
    'ml': 'mL',
    'milliliter': 'mL',
    'millilitre': 'mL',
    'milliliters': 'mL',
    'millilitres': 'mL',
    'ounce': 'oz',
    'ounces': 'oz',
    'pound': 'lb',
    'pounds': 'lb',
    'piece': 'pcs',
    'pieces': 'pcs',
    'kg': 'kg',
    'g': 'g',
    'lb': 'lb',
    'oz': 'oz',
    'cup': 'cup',
    'cups': 'cup',
  };

  String _normalizeUnit(String? unit) {
    if (unit == null || unit.isEmpty) return 'pcs';
    final normalized = unit.trim().toLowerCase();
    if (_units.contains(unit)) return unit;
    if (_unitAliases.containsKey(normalized)) {
      return _unitAliases[normalized]!;
    }
    return 'pcs';
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return products.take(5).toList();
    }

    return products
        .where(
            (product) => product.name?.toLowerCase().contains(query) ?? false)
        .take(6)
        .toList();
  }

  void _selectProduct(Product product) {
    _selectedProductId = product.id;
    _selectedCategoryId = product.productCategoryId;
    _nameController.text = product.name ?? '';
    if (product.quantity != null && product.quantity! > 0) {
      _qtyController.text = product.quantity!.toString();
    }
    _unit = _normalizeUnit(product.units);
    _searchQuery = product.name?.trim() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyController.text) ?? 1.0;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(shoppingListDetailProvider(widget.listId).notifier)
        .addItem(
          name: name,
          quantity: qty,
          unit: _unit,
          productId: _selectedProductId,
          categoryId: _selectedCategoryId,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Item',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            onChanged: (value) {
              setState(() {
                if (_selectedProductId != null &&
                    value.trim() != _searchQuery.trim()) {
                  _selectedProductId = null;
                  _selectedCategoryId = null;
                }
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search catalogue or type freely...',
              hintStyle: const TextStyle(
                  color: Colors.white38, fontFamily: 'Poppins', fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              final productsAsync = ref.watch(productListProvider);
              final suggestions = productsAsync.when(
                data: _filterProducts,
                loading: () => const [],
                error: (_, __) => const [],
              );

              if (suggestions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final product = suggestions[index];
                      return Material(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _selectProduct(product);
                            });
                            FocusScope.of(context).unfocus();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white54, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name ?? 'Unnamed product',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product.quantity?.toStringAsFixed(0) ?? '1'} ${product.units ?? _unit}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          // Qty + Unit row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    labelText: 'Qty',
                    labelStyle: const TextStyle(
                        color: Colors.white54, fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    labelStyle: const TextStyle(
                        color: Colors.white54, fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _unit = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Add to List',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
