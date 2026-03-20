import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/shopping/data/repositories/product_repository.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product.dart';
import 'package:shop_list_app/features/shopping/domain/repositories/i_product_repository.dart';
import 'package:shop_list_app/features/shopping/domain/usecases/add_product_use_case.dart';
import 'package:shop_list_app/features/shopping/domain/usecases/delete_product_use_case.dart';
import 'package:shop_list_app/features/shopping/domain/usecases/get_all_products_use_case.dart';
import 'package:shop_list_app/features/shopping/domain/usecases/get_products_by_category_use_case.dart';
import 'package:shop_list_app/features/shopping/domain/usecases/update_product_use_case.dart';

// ── Infrastructure providers ─────────────────────────────────────────────────

/// Provides the [IProductRepository] implementation.
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepository(ref.watch(databaseProvider));
});

// ── Use-case providers ───────────────────────────────────────────────────────

final getAllProductsUseCaseProvider = Provider<GetAllProductsUseCase>((ref) {
  return GetAllProductsUseCase(ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

final getProductsByCategoryUseCaseProvider =
    Provider<GetProductsByCategoryUseCase>((ref) {
  return GetProductsByCategoryUseCase(ref.watch(productRepositoryProvider));
});

// ── UI filter state ──────────────────────────────────────────────────────────

/// Current search text entered by the user on the product list page.
/// Auto-disposed so it resets when the page is unmounted.
final productSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Currently active category filter on the product list page (null = All).
/// Auto-disposed so it resets when the page is unmounted.
final productSelectedCategoryProvider =
    StateProvider.autoDispose<int?>((ref) => null);

// ── ViewModel (product list) ─────────────────────────────────────────────────

/// Central state provider for the product list.
///
/// Exposes an [AsyncValue<List<Product>>] and mutation methods.
/// Views must NOT call repositories directly; they interact only through this
/// notifier and the filter-state providers above.
final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() => _fetchAll();

  Future<List<Product>> _fetchAll() async {
    final result = await ref.read(getAllProductsUseCaseProvider).call();
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<Either<Failure, int>> addProduct(Product product) async {
    final result = await ref.read(addProductUseCaseProvider).call(product);
    if (result.isRight()) state = await AsyncValue.guard(_fetchAll);
    return result;
  }

  Future<Either<Failure, bool>> updateProduct(Product product) async {
    final result = await ref.read(updateProductUseCaseProvider).call(product);
    if (result.isRight()) state = await AsyncValue.guard(_fetchAll);
    return result;
  }

  Future<Either<Failure, bool>> deleteProduct(int id) async {
    final result = await ref.read(deleteProductUseCaseProvider).call(id);
    if (result.isRight()) state = await AsyncValue.guard(_fetchAll);
    return result;
  }
}

// ── Derived provider (filtered list) ─────────────────────────────────────────

/// Derives a filtered product list from [productListProvider] and the current
/// UI filter state.  The View should display this list rather than the raw one.
final filteredProductsProvider = Provider.autoDispose<List<Product>>((ref) {
  final asyncProducts = ref.watch(productListProvider);
  final query = ref.watch(productSearchQueryProvider);
  final categoryId = ref.watch(productSelectedCategoryProvider);

  return asyncProducts.maybeWhen(
    data: (products) => products.where((p) {
      final matchesSearch = query.isEmpty ||
          (p.name?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchesCategory =
          categoryId == null || p.productCategoryId == categoryId;
      return matchesSearch && matchesCategory;
    }).toList(),
    orElse: () => [],
  );
});

// ── ViewModel (category-detail products) ─────────────────────────────────────

/// ViewModel for the list of products belonging to a single category.
/// Used by [ProductCategoryDetailPage].  Keyed by the category id.
final categoryProductsProvider =
    AsyncNotifierProvider.family<CategoryProductsNotifier, List<Product>, int>(
  CategoryProductsNotifier.new,
);

class CategoryProductsNotifier extends FamilyAsyncNotifier<List<Product>, int> {
  @override
  Future<List<Product>> build(int arg) => _fetchByCategory(arg);

  Future<List<Product>> _fetchByCategory(int categoryId) async {
    final result =
        await ref.read(getProductsByCategoryUseCaseProvider).call(categoryId);
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchByCategory(arg));
  }
}
