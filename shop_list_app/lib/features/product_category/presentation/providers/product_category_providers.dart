import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/product_category/data/datasources/product_category_data_source.dart';
import 'package:shop_list_app/features/product_category/data/repositories/product_category_repository.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/domain/repositories/i_product_category_repository.dart';
import 'package:shop_list_app/features/product_category/domain/usecases/create_product_category_use_case.dart';
import 'package:shop_list_app/features/product_category/domain/usecases/delete_product_category_use_case.dart';
import 'package:shop_list_app/features/product_category/domain/usecases/reorder_product_categories_use_case.dart';
import 'package:shop_list_app/features/product_category/domain/usecases/update_product_category_use_case.dart';
import 'package:shop_list_app/features/product_category/domain/usecases/watch_product_categories_use_case.dart';

// -- Infrastructure providers -------------------------------------------------

/// Provides the [ProductCategoryDataSource] (Drift DAO).
final productCategoryDataSourceProvider =
    Provider<ProductCategoryDataSource>((ref) {
  return ProductCategoryDataSource(ref.watch(databaseProvider));
});

/// Provides the [IProductCategoryRepository] implementation.
final productCategoryRepositoryProvider =
    Provider<IProductCategoryRepository>((ref) {
  return ProductCategoryRepository(
    ref.watch(productCategoryDataSourceProvider),
  );
});

// -- Use-case providers -------------------------------------------------------

final watchCategoriesUseCaseProvider =
    Provider<WatchProductCategoriesUseCase>((ref) {
  return WatchProductCategoriesUseCase(
      ref.watch(productCategoryRepositoryProvider));
});

final createCategoryUseCaseProvider =
    Provider<CreateProductCategoryUseCase>((ref) {
  return CreateProductCategoryUseCase(
      ref.watch(productCategoryRepositoryProvider));
});

final updateCategoryUseCaseProvider =
    Provider<UpdateProductCategoryUseCase>((ref) {
  return UpdateProductCategoryUseCase(
      ref.watch(productCategoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider =
    Provider<DeleteProductCategoryUseCase>((ref) {
  return DeleteProductCategoryUseCase(
      ref.watch(productCategoryRepositoryProvider));
});

final reorderCategoriesUseCaseProvider =
    Provider<ReorderProductCategoriesUseCase>((ref) {
  return ReorderProductCategoriesUseCase(
      ref.watch(productCategoryRepositoryProvider));
});

// -- Stream provider (raw) ----------------------------------------------------

/// Emits the category list whenever the database changes.
/// Errors from the repository are surfaced as [AsyncError].
final watchCategoriesProvider =
    StreamProvider<List<ProductCategory>>((ref) async* {
  final useCase = ref.watch(watchCategoriesUseCaseProvider);
  yield* useCase.call().map((either) => either.fold(
        (failure) => throw failure,
        (list) => list,
      ));
});

// -- State-notifier provider --------------------------------------------------

/// Central state provider for the product-category list.
///
/// The UI should prefer watching [productCategoryListProvider] which supplies
/// an [AsyncValue<List<ProductCategory>>] with loading / error / data states.
final productCategoryListProvider =
    AsyncNotifierProvider<ProductCategoryListNotifier, List<ProductCategory>>(
  ProductCategoryListNotifier.new,
);

// -- Notifier -----------------------------------------------------------------

class ProductCategoryListNotifier extends AsyncNotifier<List<ProductCategory>> {
  @override
  Future<List<ProductCategory>> build() async {
    final useCase = ref.read(watchCategoriesUseCaseProvider);

    Completer<List<ProductCategory>>? completer = Completer();

    final subscription = useCase.call().listen(
      (either) {
        either.fold(
          (failure) {
            if (completer != null && !completer!.isCompleted) {
              completer!.completeError(failure);
            } else {
              state = AsyncError(failure, StackTrace.current);
            }
          },
          (categories) {
            if (completer != null && !completer!.isCompleted) {
              completer!.complete(categories);
            } else {
              state = AsyncData(categories);
            }
          },
        );
      },
      onError: (Object e, StackTrace st) {
        if (completer != null && !completer!.isCompleted) {
          completer!.completeError(e, st);
        } else {
          state = AsyncError(e, st);
        }
      },
    );

    ref.onDispose(() {
      subscription.cancel();
      completer = null;
    });

    final result = await completer!.future;
    completer = null;
    return result;
  }

  // -- Mutations --------------------------------------------------------------

  Future<Either<Failure, ProductCategory>> createCategory({
    required String name,
    String? colorHex,
    String? iconName,
  }) async {
    return ref.read(createCategoryUseCaseProvider).call(
          name: name,
          colorHex: colorHex,
          iconName: iconName,
        );
  }

  Future<Either<Failure, ProductCategory>> updateCategory({
    required int id,
    required String name,
    String? colorHex,
    String? iconName,
    int? sortOrder,
  }) async {
    return ref.read(updateCategoryUseCaseProvider).call(
          id: id,
          name: name,
          colorHex: colorHex,
          iconName: iconName,
          sortOrder: sortOrder,
        );
  }

  Future<Either<Failure, bool>> deleteCategory(int id,
      {bool force = false}) async {
    final useCase = ref.read(deleteCategoryUseCaseProvider);
    return force ? useCase.forceDelete(id) : useCase.call(id);
  }

  Future<Either<Failure, bool>> reorderCategories(List<int> orderedIds) async {
    return ref.read(reorderCategoriesUseCaseProvider).call(orderedIds);
  }

  /// Returns the number of products assigned to [categoryId].
  /// Exposed here so Views never need to access the repository directly.
  Future<int> countProductsForCategory(int categoryId) {
    return ref
        .read(productCategoryRepositoryProvider)
        .countProductsForCategory(categoryId);
  }
}
