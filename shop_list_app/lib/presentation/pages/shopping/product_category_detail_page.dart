import 'package:flutter/material.dart';
import 'package:shop_list_app/domain/entities/shopping/product_category.dart'
    as cat_model;
import 'package:shop_list_app/domain/entities/shopping/product.dart'
    as prod_model;
import 'package:shop_list_app/domain/repositories/shopping/i_product_category_repository.dart';
import 'package:shop_list_app/domain/repositories/shopping/i_product_repository.dart';
import 'package:shop_list_app/data/datasources/shopping/product_category_data_source.dart';
import 'package:shop_list_app/data/repositories/shopping/product_category_repository.dart';
import 'package:shop_list_app/data/repositories/shopping/product_repository.dart';
import 'package:shop_list_app/core/database/app_database.dart';

class ProductCategoryDetailPage extends StatefulWidget {
  final cat_model.ProductCategory category;

  const ProductCategoryDetailPage({super.key, required this.category});

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
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF181725), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF181725),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF181725)),
            onPressed: _editCategory,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF3603F)),
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
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F2),
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: category.photo != null && category.photo!.isNotEmpty
                  ? Text(
                      category.photo!,
                      style: const TextStyle(fontSize: 60),
                    )
                  : const Icon(
                      Icons.category_outlined,
                      size: 56,
                      color: Color(0xFF53B175),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            category.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF181725),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category ID: ${category.id}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF7C7C7C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181725),
                ),
              ),
              if (!_isLoading)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF53B175).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_categoryProducts.length}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF53B175),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF53B175)))
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF53B175).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: Color(0xFF53B175),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No products in this category',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C7C7C),
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categoryProducts.length,
      itemBuilder: (context, index) {
        final product = _categoryProducts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E2E2), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: product.photo != null && product.photo!.isNotEmpty
                    ? Text(product.photo!, style: const TextStyle(fontSize: 26))
                    : const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFFDBDBDB)),
              ),
            ),
            title: Text(
              product.name ?? 'Unnamed Product',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF181725),
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${product.quantity ?? 0} ${product.units ?? ''}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF7C7C7C),
                fontSize: 12,
              ),
            ),
            trailing: product.expirationDate != null
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(product.expirationDate!),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF7C7C7C),
                      ),
                    ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF181725),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF53B175),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontFamily: 'Poppins'),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final photo = photoController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a category name')),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Category updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating category: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF181725),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This category has ${_categoryProducts.length} product(s). '
          'Deleting it may affect these products.',
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
          ElevatedButton(
            onPressed: () async {
              try {
                await _categoryRepository.deleteCategory(category.id);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Category deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting category: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3603F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontFamily: 'Poppins'),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
