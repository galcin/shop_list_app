import 'package:flutter/material.dart';
import '../../domain/entities/product_category.dart' as cat_model;
import '../../domain/entities/product.dart' as prod_model;
import '../../domain/repositories/i_product_category_repository.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../data/datasources/product_category_data_source.dart';
import '../../data/repositories/product_category_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class ProductCategoryDetailPage extends StatefulWidget {
  final cat_model.ProductCategory category;

  const ProductCategoryDetailPage({required this.category});

  @override
  _ProductCategoryDetailPageState createState() =>
      _ProductCategoryDetailPageState();
}

class _ProductCategoryDetailPageState extends State<ProductCategoryDetailPage> {
  late final IProductCategoryRepository _categoryRepository;
  late final IProductRepository _productRepository;
  late final AppDatabase _database;
  List<prod_model.Product> _categoryProducts = [];
  bool _isLoading = true;

  cat_model.ProductCategory get category => widget.category;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase.instance;
    _categoryRepository =
        ProductCategoryRepository(ProductCategoryDataSource(_database));
    _productRepository = ProductRepository(_database);
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products =
          await _productRepository.getProductsByCategory(category.id);

      if (mounted) {
        setState(() {
          _categoryProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editCategory,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteCategory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(),
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: category.photo != null && category.photo!.isNotEmpty
                  ? Text(
                      category.photo!,
                      style: TextStyle(fontSize: 72),
                    )
                  : Icon(
                      Icons.category,
                      size: 72,
                      color: Colors.grey[400],
                    ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Category ID: ${category.id}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products in this category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isLoading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_categoryProducts.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _categoryProducts.isEmpty
                  ? _buildEmptyProducts()
                  : _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No products in this category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _categoryProducts.length,
      itemBuilder: (context, index) {
        final product = _categoryProducts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: product.photo != null && product.photo!.isNotEmpty
                    ? Text(product.photo!, style: TextStyle(fontSize: 28))
                    : Icon(Icons.shopping_bag, color: Colors.grey[400]),
              ),
            ),
            title: Text(
              product.name ?? 'Unnamed Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${product.quantity ?? 0} ${product.units ?? ''}'),
            trailing: product.expirationDate != null
                ? Text(
                    _formatDate(product.expirationDate!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editCategory() {
    final nameController = TextEditingController(text: category.name);
    final photoController = TextEditingController(text: category.photo ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final photo = photoController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a category name')),
                );
                return;
              }

              try {
                await _categoryRepository.updateCategory(
                  cat_model.ProductCategory(
                    id: category.id,
                    name: name,
                    photo: photo.isEmpty ? null : photo,
                  ),
                );

                Navigator.pop(context);
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating category: $e')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This category has ${_categoryProducts.length} products. '
          'Deleting it may affect these products.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _categoryRepository.deleteCategory(category.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting category: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
