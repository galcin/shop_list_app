import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/domain/repositories/i_product_category_repository.dart';
import 'package:shop_list_app/features/products/domain/entities/product.dart';
import 'package:shop_list_app/features/products/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';

/// Use case to convert shopping list items to pantry items.
/// For each shopping item:
/// - If a pantry item with the same name exists in the same category, add to quantity
/// - Otherwise, create a new pantry item
class CompleteShoppingListUseCase {
  final IPantryRepository _repository;
  final IProductRepository _productRepository;
  final IProductCategoryRepository _categoryRepository;

  CompleteShoppingListUseCase(
    this._repository,
    this._productRepository,
    this._categoryRepository,
  );

  Future<Either<Failure, int>> call(
    List<ShoppingItemEntity> items,
  ) async {
    try {
      if (items.isEmpty) {
        return const Right(0);
      }

      int addedCount = 0;

      // Get all existing pantry items to check for duplicates
      final existingItems = await _repository.getAll();
      final categories = await _categoryRepository.getAllCategories();
      final products = await _productRepository.getAllProducts();
      final productsByNormalizedName = _groupProductsByNormalizedName(products);
      final productCategoryByProductId = <int, int?>{};

      for (final item in items) {
        final resolvedCategoryId = await _resolveCategoryId(
          item,
          categories,
          productCategoryByProductId,
        );
        final resolvedProductId = _resolveProductId(
          item,
          resolvedCategoryId,
          productsByNormalizedName,
          products,
        );

        // Find if an item with the same name and category already exists
        final matchingItems = existingItems.where(
          (pItem) =>
              pItem.name.toLowerCase() == item.name.toLowerCase() &&
              pItem.categoryId == resolvedCategoryId,
        );
        final existingItem = matchingItems.isEmpty ? null : matchingItems.first;

        if (existingItem != null) {
          // Update existing item: add quantities
          final updated = existingItem.copyWith(
            quantity: existingItem.quantity + item.quantity,
            productId: existingItem.productId ?? resolvedProductId,
            updatedAt: DateTime.now(),
          );
          await _repository.update(updated);
          addedCount++;
        } else {
          // Create new pantry item
          final newItem = PantryItem(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            categoryId: resolvedCategoryId,
            productId: resolvedProductId,
            expiryDate: null,
            purchasedDate: DateTime.now(),
            location: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSynced: false,
            isDeleted: false,
          );
          final id = await _repository.save(newItem);
          if (id > 0) {
            addedCount++;
          }
        }
      }

      return Right(addedCount);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to complete shopping list: $e'),
      );
    }
  }

  Future<int> _resolveCategoryId(
    ShoppingItemEntity item,
    List<ProductCategory> categories,
    Map<int, int?> productCategoryByProductId,
  ) async {
    if (item.categoryId != null) return item.categoryId!;

    if (item.productId != null) {
      final productId = item.productId!;
      if (!productCategoryByProductId.containsKey(productId)) {
        final product = await _productRepository.getProductById(productId);
        productCategoryByProductId[productId] = product?.productCategoryId;
      }

      final categoryId = productCategoryByProductId[productId];
      if (categoryId != null) return categoryId;
    }

    final inferred = _inferCategoryIdFromName(item.name, categories);
    if (inferred != null) return inferred;

    return _fallbackCategoryId(categories);
  }

  int? _inferCategoryIdFromName(
      String itemName, List<ProductCategory> categories) {
    final normalized = itemName.toLowerCase();

    final meatKeywords = [
      'chicken',
      'beef',
      'pork',
      'lamb',
      'turkey',
      'meat',
      'steak',
      'mince',
      'ground',
      'fish',
      'salmon',
      'tuna',
      'shrimp',
      'prawn',
      'seafood',
    ];

    final dairyKeywords = [
      'milk',
      'cheese',
      'yogurt',
      'yoghurt',
      'butter',
      'cream',
      'egg',
    ];

    final fruitKeywords = [
      'apple',
      'banana',
      'orange',
      'berry',
      'grape',
      'mango',
      'fruit',
      'pineapple',
    ];

    final vegetableKeywords = [
      'carrot',
      'broccoli',
      'lettuce',
      'spinach',
      'tomato',
      'onion',
      'potato',
      'pepper',
      'vegetable',
    ];

    final bakeryKeywords = [
      'bread',
      'bun',
      'roll',
      'bagel',
      'croissant',
      'cake',
      'pastry',
      'bakery',
    ];

    final beveragesKeywords = [
      'juice',
      'soda',
      'water',
      'coffee',
      'tea',
      'drink',
      'beverage',
    ];

    if (_containsAny(normalized, meatKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['meat', 'poultry', 'protein', 'fish', 'seafood'],
      );
    }

    if (_containsAny(normalized, dairyKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['dairy', 'milk', 'egg'],
      );
    }

    if (_containsAny(normalized, fruitKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['fruit'],
      );
    }

    if (_containsAny(normalized, vegetableKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['vegetable', 'veggie'],
      );
    }

    if (_containsAny(normalized, bakeryKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['bakery', 'bread'],
      );
    }

    if (_containsAny(normalized, beveragesKeywords)) {
      return _findCategoryIdByCategoryKeywords(
        categories,
        const ['beverage', 'drink'],
      );
    }

    return null;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  int? _findCategoryIdByCategoryKeywords(
    List<ProductCategory> categories,
    List<String> categoryKeywords,
  ) {
    for (final category in categories) {
      final normalizedName = category.name.toLowerCase();
      if (categoryKeywords.any(normalizedName.contains)) {
        return category.id;
      }
    }
    return null;
  }

  int _fallbackCategoryId(List<ProductCategory> categories) {
    final fallbackNames = ['snacks', 'other', 'misc', 'pantry', 'grocery'];

    for (final category in categories) {
      final normalizedName = category.name.toLowerCase();
      if (fallbackNames.any(normalizedName.contains)) {
        return category.id;
      }
    }

    if (categories.isNotEmpty) {
      return categories.first.id;
    }

    // Absolute fallback for edge cases with no categories available.
    return 1;
  }

  Map<String, List<Product>> _groupProductsByNormalizedName(
    List<Product> products,
  ) {
    final map = <String, List<Product>>{};
    for (final product in products) {
      final rawName = product.name;
      if (rawName == null || rawName.trim().isEmpty) continue;
      final key = _normalizeName(rawName);
      map.putIfAbsent(key, () => []).add(product);
    }
    return map;
  }

  int? _resolveProductId(
    ShoppingItemEntity item,
    int resolvedCategoryId,
    Map<String, List<Product>> productsByNormalizedName,
    List<Product> allProducts,
  ) {
    if (item.productId != null) return item.productId;

    final normalizedItemName = _normalizeName(item.name);

    List<Product> candidates =
        productsByNormalizedName[normalizedItemName] ?? const [];

    if (candidates.isEmpty) {
      candidates = allProducts.where((product) {
        final productName = product.name;
        if (productName == null || productName.trim().isEmpty) return false;

        final normalizedProductName = _normalizeName(productName);

        if (normalizedProductName.contains(normalizedItemName) ||
            normalizedItemName.contains(normalizedProductName)) {
          return true;
        }

        final itemTokens = _tokenize(normalizedItemName);
        final productTokens = _tokenize(normalizedProductName);
        if (itemTokens.isEmpty || productTokens.isEmpty) return false;

        final overlap = itemTokens.intersection(productTokens);
        return overlap.isNotEmpty;
      }).toList();
    }

    if (candidates.isEmpty) return null;

    final sameCategory = candidates
        .where((p) => p.productCategoryId == resolvedCategoryId)
        .toList();

    final pool = sameCategory.isNotEmpty ? sameCategory : candidates;

    final withPhoto = pool.where((p) => (p.photo ?? '').trim().isNotEmpty);
    final bestMatch = withPhoto.isNotEmpty ? withPhoto.first : pool.first;
    return bestMatch.id;
  }

  String _normalizeName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Set<String> _tokenize(String value) {
    return value.split(' ').where((token) => token.trim().length >= 3).toSet();
  }
}
