import 'package:flutter/material.dart';
import '../../../service/models/product_category.dart' as model;
import '../../../core/repository/product_category_repository.dart';
import '../../../service/storage/local_db/app_database.dart';
import 'product_category_detail_page.dart';

class ProductCategoryViewPage extends StatefulWidget {
  @override
  _ProductCategoryViewPageState createState() =>
      _ProductCategoryViewPageState();
}

class _ProductCategoryViewPageState extends State<ProductCategoryViewPage> {
  late final ProductCategoryRepository _categoryRepository;
  late final AppDatabase _database;
  List<model.ProductCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _database = AppDatabase.instance;
    _categoryRepository = ProductCategoryRepository(_database);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _categoryRepository.getAllCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<model.ProductCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }
    return _categories
        .where((category) =>
            category.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Categories'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoryGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search categories...',
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

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(_filteredCategories[index]);
      },
    );
  }

  Widget _buildCategoryCard(model.ProductCategory category) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _viewCategoryDetails(category),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon/Emoji
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: category.photo != null && category.photo!.isNotEmpty
                      ? Text(
                          category.photo!,
                          style: TextStyle(fontSize: 42),
                        )
                      : Icon(
                          Icons.category,
                          size: 42,
                          color: Colors.grey[400],
                        ),
                ),
              ),
              SizedBox(height: 8),
              // Category Name
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add a new category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _viewCategoryDetails(model.ProductCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductCategoryDetailPage(category: category),
      ),
    ).then((_) => _loadCategories());
  }

  void _addCategory() {
    _showCategoryDialog();
  }

  void _showCategoryDialog({model.ProductCategory? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final photoController = TextEditingController(text: category?.photo ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
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
                if (isEditing) {
                  await _categoryRepository.updateCategory(
                    model.ProductCategory(
                      id: category.id,
                      name: name,
                      photo: photo.isEmpty ? null : photo,
                    ),
                  );
                } else {
                  await _categoryRepository.addCategory(
                    model.ProductCategory(
                      id: 0, // Will be auto-generated
                      name: name,
                      photo: photo.isEmpty ? null : photo,
                    ),
                  );
                }

                Navigator.pop(context);
                _loadCategories();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing
                        ? 'Category updated'
                        : 'Category added successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving category: $e')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }
}
