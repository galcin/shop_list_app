import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/theme/colors.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';

class AddPantryItemBottomSheet extends ConsumerStatefulWidget {
  const AddPantryItemBottomSheet({super.key});

  @override
  ConsumerState<AddPantryItemBottomSheet> createState() =>
      _AddPantryItemBottomSheetState();
}

class _AddPantryItemBottomSheetState
    extends ConsumerState<AddPantryItemBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  DateTime? _expiryDate;
  String _unit = 'kg';
  int? _selectedCategoryId;
  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '1.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoryListProvider);
    final productsAsync = ref.watch(productListProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Add Pantry Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 24),

              // Item selection from products or manual entry
              Text(
                'Product',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              productsAsync.when(
                data: (products) {
                  return Autocomplete<Product>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return products;
                      }
                      return products
                          .where((product) => (product.name ?? '')
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    onSelected: (Product selection) {
                      setState(() {
                        _selectedProduct = selection;
                        _nameController.text = selection.name ?? '';
                        if (selection.productCategoryId != null) {
                          _selectedCategoryId = selection.productCategoryId;
                        }
                      });
                    },
                    fieldViewBuilder: (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // Sync the controller with our name controller
                      _nameController = textEditingController;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search or enter product name...',
                          fillColor: const Color(0xFF2A2A2A),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _selectedProduct != null
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedProduct = null;
                                      textEditingController.clear();
                                    });
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.grey),
                                )
                              : null,
                        ),
                      );
                    },
                    optionsViewBuilder: (
                      context,
                      onSelected,
                      options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: const Color(0xFF2A2A2A),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    option.name ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    'Cat: ${option.productCategoryId ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Loading products...',
                    fillColor: Color(0xFF2A2A2A),
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                error: (error, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error loading products',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter item name manually...',
                        fillColor: const Color(0xFF2A2A2A),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantity and unit row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            fillColor: const Color(0xFF2A2A2A),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        DropdownMenu<String>(
                          initialSelection: _unit,
                          onSelected: (value) {
                            if (value != null) {
                              setState(() => _unit = value);
                            }
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'kg', label: 'kg'),
                            DropdownMenuEntry(value: 'g', label: 'g'),
                            DropdownMenuEntry(value: 'L', label: 'L'),
                            DropdownMenuEntry(value: 'ml', label: 'ml'),
                            DropdownMenuEntry(value: 'pcs', label: 'pcs'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category selection
              categoriesAsync.when(
                data: (categories) {
                  _selectedCategoryId ??= categories.firstOrNull?.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownMenu<int>(
                        initialSelection: _selectedCategoryId,
                        onSelected: (value) {
                          if (value != null) {
                            setState(() => _selectedCategoryId = value);
                          }
                        },
                        dropdownMenuEntries: categories
                            .map((cat) => DropdownMenuEntry(
                                  value: cat.id,
                                  label: '${cat.iconName ?? "📦"} ${cat.name}',
                                ))
                            .toList(),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Error loading categories: $error'),
              ),
              const SizedBox(height: 16),

              // Expiry date picker
              Text(
                'Expiry Date (optional)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectExpiryDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _expiryDate != null
                            ? '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}'
                            : 'Select date',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Add to Pantry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _expiryDate = pickedDate);
    }
  }

  Future<void> _handleAddItem() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter item name');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showError('Please enter a valid quantity');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(pantryItemsProvider.notifier).addItem(
            name: _nameController.text.trim(),
            quantity: quantity,
            unit: _unit,
            categoryId: _selectedCategoryId!,
            productId: _selectedProduct?.id,
            expiryDate: _expiryDate,
          );

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('Item added to pantry');
      }
    } catch (e) {
      _showError('Failed to add item: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[400],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
