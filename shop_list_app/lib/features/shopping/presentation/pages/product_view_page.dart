import 'package:flutter/material.dart';
import '../../domain/entities/product.dart' as prod_model;
import '../../domain/entities/product_category.dart' as cat_model;
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/repositories/i_product_category_repository.dart';
import '../../data/datasources/product_category_data_source.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/product_category_repository.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'product_detail_page.dart';

class ProductViewPage extends StatefulWidget {
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
    _categoryRepository = ProductCategoryRepository(ProductCategoryDataSource(_database));
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
      appBar: AppBar(
        title: Text('Products'),
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
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(prod_model.Product product) {
    final isExpiringSoon = product.expirationDate != null &&
        product.expirationDate!.isBefore(DateTime.now().add(Duration(days: 7)));
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product Photo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: product.photo != null && product.photo!.isNotEmpty
                      ? Text(
                          product.photo!,
                          style: TextStyle(fontSize: 32),
                        )
                      : Icon(Icons.shopping_bag,
                          size: 30, color: Colors.grey[400]),
                ),
              ),
              SizedBox(width: 16),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unnamed Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${product.quantity ?? 0} ${product.units ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (product.expirationDate != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isExpired
                                ? Colors.red
                                : isExpiringSoon
                                    ? Colors.orange
                                    : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Exp: ${_formatDate(product.expirationDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired
                                  ? Colors.red
                                  : isExpiringSoon
                                      ? Colors.orange
                                      : Colors.grey[600],
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
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editProduct(product);
                      break;
                    case 'delete':
                      _deleteProduct(product);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
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
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
        title: Text('Filter by Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Categories'),
              leading: Radio<int?>(
                value: null,
                groupValue: _selectedCategoryId,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ..._categories.map((category) => ListTile(
                  title: Text(category.name),
                  leading: Radio<int?>(
                    value: category.id,
                    groupValue: _selectedCategoryId,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
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
          title: Text(isEditing ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitsController,
                        decoration: InputDecoration(
                          labelText: 'Units',
                          border: OutlineInputBorder(),
                          hintText: 'kg, pcs',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: photoController,
                  decoration: InputDecoration(
                    labelText: 'Emoji Icon',
                    border: OutlineInputBorder(),
                    hintText: '🍎',
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  decoration: InputDecoration(
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
                                style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
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
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: builderContext,
                      initialDate:
                          selectedDate ?? DateTime.now().add(Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiration Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDate != null
                          ? _formatDate(selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        color:
                            selectedDate != null ? Colors.black : Colors.grey,
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final quantityText = quantityController.text.trim();
                final units = unitsController.text.trim();
                final photo = photoController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a product name')),
                  );
                  return;
                }

                if (quantityText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a quantity')),
                  );
                  return;
                }

                final quantity = double.tryParse(quantityText);
                if (quantity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity')),
                  );
                  return;
                }

                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a category')),
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
                        productCategoryId: selectedCategoryId!,
                      ),
                    );
                    Navigator.pop(builderContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Product updated successfully')),
                    );
                  } else {
                    await _productRepository.addProduct(
                      prod_model.Product(
                        id: 0, // Will be auto-generated
                        name: name,
                        quantity: quantity,
                        units: units.isEmpty ? null : units,
                        photo: photo.isEmpty ? null : photo,
                        expirationDate: selectedDate,
                        productCategoryId: selectedCategoryId!,
                      ),
                    );
                    Navigator.pop(builderContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Product added successfully')),
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
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (product.id != null) {
                try {
                  await _productRepository.deleteProduct(product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product deleted')),
                  );
                  _loadProducts(); // Reload the list
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
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
