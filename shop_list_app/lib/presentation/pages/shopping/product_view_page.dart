import 'package:flutter/material.dart';
import 'package:shop_list_app/domain/entities/shopping/product.dart'
    as prod_model;
import 'package:shop_list_app/domain/entities/shopping/product_category.dart'
    as cat_model;
import 'package:shop_list_app/domain/repositories/shopping/i_product_repository.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';
import 'package:shop_list_app/data/datasources/shopping/product_category_data_source.dart';
import 'package:shop_list_app/data/repositories/shopping/product_repository.dart';
import 'package:shop_list_app/data/repositories/shopping/product_category_repository.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/presentation/pages/shopping/product_detail_page.dart';

class ProductViewPage extends StatefulWidget {
  const ProductViewPage({super.key});

  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  late final IProductRepository _productRepository;
  late final IProductCategoryRepository _categoryRepository;
  late final AppDatabase _database;
  List<prod_model.Product> _products = [];
  List<cat_model.ProductCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    print('[ProductView] Initializing product view page');
    // Use the singleton instance that was initialized at startup
    _database = AppDatabase.instance;
    _productRepository = ProductRepository(_database);
    _categoryRepository =
        ProductCategoryRepository(ProductCategoryDataSource(_database));
    // Defer loading slightly to ensure everything is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[ProductView] Starting to load products');
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    print('[ProductView] _loadProducts called');
    if (!mounted) {
      print('[ProductView] Widget not mounted, aborting');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('[ProductView] Fetching all products...');
      final products = await _productRepository.getAllProducts();
      print('[ProductView] Loaded ${products.length} products');

      print('[ProductView] Fetching all categories...');
      final categories = await _categoryRepository.getAllCategories();
      print('[ProductView] Loaded ${categories.length} categories');

      if (!mounted) {
        print('[ProductView] Widget unmounted after data fetch');
        return;
      }

      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
      print('[ProductView] State updated successfully');
    } catch (e, stackTrace) {
      print('[ProductView] Error loading products: $e');
      print('[ProductView] Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Don't close the singleton database instance
    super.dispose();
  }

  List<prod_model.Product> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false;
      final matchesCategory = _selectedCategoryId == null ||
          product.productCategoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_categories.isNotEmpty) _buildCategoryChips(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: Icon(Icons.add),
        tooltip: 'Add Product',
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(prod_model.Product product) {
    final isExpiringSoon = product.expirationDate != null &&
        product.expirationDate!
            .isBefore(DateTime.now().add(const Duration(days: 7)));
    final isExpired = product.expirationDate != null &&
        product.expirationDate!.isBefore(DateTime.now());

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
                  if (value == 'edit') _editProduct(product);
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

  void _showFilterDialog() {
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
                groupValue: _selectedCategoryId,
                activeColor: const Color(0xFF53B175),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                  Navigator.pop(context);
                },
              ),
            ),
            ..._categories.map(
              (category) => ListTile(
                title: Text(
                  category.name,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: Color(0xFF181725)),
                ),
                leading: Radio<int?>(
                  value: category.id,
                  groupValue: _selectedCategoryId,
                  activeColor: const Color(0xFF53B175),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
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

  void _addProduct() {
    _showProductDialog();
  }

  void _editProduct(prod_model.Product product) {
    _showProductDialog(product: product);
  }

  void _showProductDialog({prod_model.Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final quantityController =
        TextEditingController(text: product?.quantity?.toString() ?? '');
    final unitsController = TextEditingController(text: product?.units ?? '');
    final photoController = TextEditingController(text: product?.photo ?? '');
    DateTime? selectedDate = product?.expirationDate;
    int? selectedCategoryId = product?.productCategoryId ??
        (_categories.isNotEmpty ? _categories.first.id : null);

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
                    hintText: '🍎',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
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

                try {
                  if (isEditing && product.id != null) {
                    await _productRepository.updateProduct(
                      prod_model.Product(
                        id: product.id,
                        name: name,
                        quantity: quantity,
                        units: units.isEmpty ? null : units,
                        photo: photo.isEmpty ? null : photo,
                        expirationDate: selectedDate,
                        productCategoryId: selectedCategoryId,
                      ),
                    );
                    Navigator.pop(builderContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Product updated successfully')),
                    );
                  } else {
                    await _productRepository.addProduct(
                      prod_model.Product(
                        id: 0,
                        name: name,
                        quantity: quantity,
                        units: units.isEmpty ? null : units,
                        photo: photo.isEmpty ? null : photo,
                        expirationDate: selectedDate,
                        productCategoryId: selectedCategoryId,
                      ),
                    );
                    Navigator.pop(builderContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Product added successfully')),
                    );
                  }
                  _loadProducts();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving product: $e')),
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
                try {
                  await _productRepository.deleteProduct(product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')),
                  );
                  _loadProducts();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
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

  void _viewProductDetails(prod_model.Product product) async {
    final category = product.productCategoryId != null
        ? await _categoryRepository.getCategoryById(product.productCategoryId!)
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          category: category,
        ),
      ),
    ).then((_) => _loadProducts()); // Reload when coming back
  }
}
