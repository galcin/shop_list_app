import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart'
    as prod_model;
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart'
    as cat_model;
import 'package:shop_list_app/features/shopping/presentation/pages/product_detail_page.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/shopping/presentation/providers/product_providers.dart';

/// View — delegates all data operations to [ProductListNotifier] (ViewModel).
/// No repository or database access happens inside this widget.
class ProductViewPage extends ConsumerStatefulWidget {
  const ProductViewPage({super.key});

  @override
  ConsumerState<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends ConsumerState<ProductViewPage> {
  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categories =
        ref.watch(productCategoryListProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Color(0xFF181725),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF181725)),
            onPressed: () => _showFilterDialog(categories),
          ),
        ],
      ),
      body: asyncProducts.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF53B175)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFF3603F), size: 48),
              const SizedBox(height: 12),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins', color: Color(0xFF7C7C7C)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productListProvider),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53B175)),
                child: const Text('Retry',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
        data: (_) => Column(
          children: [
            _buildSearchBar(),
            if (categories.isNotEmpty) _buildCategoryChips(categories),
            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildProductList(filteredProducts),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(categories: categories),
        backgroundColor: const Color(0xFF53B175),
        foregroundColor: Colors.white,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChips(List<cat_model.ProductCategory> categories) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(null, 'All'),
          ...categories.map((c) => _buildChip(c.id, c.name)),
        ],
      ),
    );
  }

  Widget _buildChip(int? catId, String label) {
    final selected = ref.watch(productSelectedCategoryProvider) == catId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(productSelectedCategoryProvider.notifier).state = catId,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF53B175) : const Color(0xFFF2F3F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  selected ? const Color(0xFF53B175) : const Color(0xFFDBDBDB),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : const Color(0xFF4C4F4D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search store',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF7C7C7C),
            fontSize: 14,
          ),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF7C7C7C), size: 20),
          filled: true,
          fillColor: const Color(0xFFF2F3F2),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ),
        onChanged: (value) =>
            ref.read(productSearchQueryProvider.notifier).state = value,
      ),
    );
  }

  Widget _buildProductList(List<prod_model.Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(prod_model.Product product) {
    final isExpiringSoon = product.expirationDate != null &&
        product.expirationDate!
            .isBefore(DateTime.now().add(const Duration(days: 7)));
    final isExpired = product.expirationDate != null &&
        product.expirationDate!.isBefore(DateTime.now());
    final expiryColor =
        isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.grey);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewProductDetails(product),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Product Photo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: product.photo != null && product.photo!.isNotEmpty
                      ? Text(
                          product.photo!,
                          style: TextStyle(fontSize: 32),
                        )
                      : const Icon(Icons.shopping_bag,
                          size: 32, color: Color(0xFFDBDBDB)),
                ),
              ),
              const SizedBox(width: 14),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unnamed Product',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF181725),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.quantity ?? 0} ${product.units ?? ''}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF7C7C7C),
                      ),
                    ),
                    if (product.expirationDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: expiryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Exp: ${_formatDate(product.expirationDate!)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: expiryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFF7C7C7C), size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    final categories =
                        ref.read(productCategoryListProvider).asData?.value ??
                            [];
                    _showProductDialog(
                        product: product, categories: categories);
                  }
                  if (value == 'delete') _deleteProduct(product);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: Color(0xFF181725)),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Color(0xFF181725)),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: Color(0xFFF3603F)),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Color(0xFFF3603F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF53B175).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 52,
              color: Color(0xFF53B175),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No products found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181725),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF7C7C7C),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog(List<cat_model.ProductCategory> categories) {
    final selectedCategoryId = ref.read(productSelectedCategoryProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Filter by Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF181725),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'All Categories',
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF181725)),
              ),
              leading: Radio<int?>(
                value: null,
                groupValue: selectedCategoryId,
                activeColor: const Color(0xFF53B175),
                onChanged: (value) {
                  ref.read(productSelectedCategoryProvider.notifier).state =
                      value;
                  Navigator.pop(context);
                },
              ),
            ),
            ...categories.map(
              (category) => ListTile(
                title: Text(
                  category.name,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: Color(0xFF181725)),
                ),
                leading: Radio<int?>(
                  value: category.id,
                  groupValue: selectedCategoryId,
                  activeColor: const Color(0xFF53B175),
                  onChanged: (value) {
                    ref.read(productSelectedCategoryProvider.notifier).state =
                        value;
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                  color: Color(0xFF53B175),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog({
    prod_model.Product? product,
    required List<cat_model.ProductCategory> categories,
  }) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final quantityController =
        TextEditingController(text: product?.quantity?.toString() ?? '');
    final unitsController = TextEditingController(text: product?.units ?? '');
    final photoController = TextEditingController(text: product?.photo ?? '');
    DateTime? selectedDate = product?.expirationDate;
    int? selectedCategoryId = product?.productCategoryId ??
        (categories.isNotEmpty ? categories.first.id : null);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Edit Product' : 'Add Product',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF181725),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitsController,
                        decoration: const InputDecoration(
                          labelText: 'Units',
                          border: OutlineInputBorder(),
                          hintText: 'kg, pcs',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: photoController,
                  decoration: const InputDecoration(
                    labelText: 'Emoji Icon',
                    border: OutlineInputBorder(),
                    hintText: '??',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        children: [
                          if (category.photo != null &&
                              category.photo!.isNotEmpty)
                            Text(category.photo!,
                                style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: builderContext,
                      initialDate: selectedDate ??
                          DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDate != null
                          ? _formatDate(selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: selectedDate != null
                            ? const Color(0xFF181725)
                            : const Color(0xFF7C7C7C),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(builderContext),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins'),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53B175),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(0, 44),
                textStyle: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final quantityText = quantityController.text.trim();
                final units = unitsController.text.trim();
                final photo = photoController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a product name')),
                  );
                  return;
                }
                if (quantityText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a quantity')),
                  );
                  return;
                }
                final quantity = double.tryParse(quantityText);
                if (quantity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid quantity')),
                  );
                  return;
                }
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }

                final productData = prod_model.Product(
                  id: isEditing ? product.id : 0,
                  name: name,
                  quantity: quantity,
                  units: units.isEmpty ? null : units,
                  photo: photo.isEmpty ? null : photo,
                  expirationDate: selectedDate,
                  productCategoryId: selectedCategoryId,
                );

                if (isEditing) {
                  final result = await ref
                      .read(productListProvider.notifier)
                      .updateProduct(productData);
                  result.fold(
                    (f) => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(f.message))),
                    (_) {
                      Navigator.pop(builderContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Product updated successfully')),
                      );
                    },
                  );
                } else {
                  final result = await ref
                      .read(productListProvider.notifier)
                      .addProduct(productData);
                  result.fold(
                    (f) => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(f.message))),
                    (_) {
                      Navigator.pop(builderContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Product added successfully')),
                      );
                    },
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(prod_model.Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Product',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF181725),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF4C4F4D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (product.id != null) {
                final result = await ref
                    .read(productListProvider.notifier)
                    .deleteProduct(product.id!);
                result.fold(
                  (f) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message))),
                  (_) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted'))),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFF3603F),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewProductDetails(prod_model.Product product) {
    final categories =
        ref.read(productCategoryListProvider).asData?.value ?? [];
    cat_model.ProductCategory? category;
    if (product.productCategoryId != null) {
      final matches =
          categories.where((c) => c.id == product.productCategoryId);
      category = matches.isNotEmpty ? matches.first : null;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
          category: category,
        ),
      ),
    ).then((_) => ref.invalidate(productListProvider));
  }
}
