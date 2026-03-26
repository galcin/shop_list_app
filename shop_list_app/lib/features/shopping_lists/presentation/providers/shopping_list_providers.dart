import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/shopping_lists/data/datasources/shopping_list_data_source.dart';
import 'package:shop_list_app/features/shopping_lists/data/repositories/shopping_list_repository_impl.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/add_item_to_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/create_shopping_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/delete_shopping_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/remove_item_from_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/rename_shopping_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/toggle_item_checked_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/watch_shopping_list_use_case.dart';
import 'package:shop_list_app/features/shopping_lists/domain/usecases/watch_shopping_lists_use_case.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final shoppingListDataSourceProvider = Provider<ShoppingListDataSource>((ref) {
  return ShoppingListDataSource(ref.watch(databaseProvider));
});

final shoppingListRepositoryProvider = Provider<IShoppingListRepository>((ref) {
  return ShoppingListRepositoryImpl(ref.watch(shoppingListDataSourceProvider));
});

// ── Use-case providers ────────────────────────────────────────────────────────

final watchShoppingListsUseCaseProvider =
    Provider<WatchShoppingListsUseCase>((ref) {
  return WatchShoppingListsUseCase(ref.watch(shoppingListRepositoryProvider));
});

final createShoppingListUseCaseProvider =
    Provider<CreateShoppingListUseCase>((ref) {
  return CreateShoppingListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final deleteShoppingListUseCaseProvider =
    Provider<DeleteShoppingListUseCase>((ref) {
  return DeleteShoppingListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final renameShoppingListUseCaseProvider =
    Provider<RenameShoppingListUseCase>((ref) {
  return RenameShoppingListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final watchShoppingListUseCaseProvider =
    Provider<WatchShoppingListUseCase>((ref) {
  return WatchShoppingListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final addItemToListUseCaseProvider = Provider<AddItemToListUseCase>((ref) {
  return AddItemToListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final removeItemFromListUseCaseProvider =
    Provider<RemoveItemFromListUseCase>((ref) {
  return RemoveItemFromListUseCase(ref.watch(shoppingListRepositoryProvider));
});

final toggleItemCheckedUseCaseProvider =
    Provider<ToggleItemCheckedUseCase>((ref) {
  return ToggleItemCheckedUseCase(ref.watch(shoppingListRepositoryProvider));
});

// ── Shopping lists overview notifier ─────────────────────────────────────────

/// Streams all shopping lists and exposes mutation helpers.
final shoppingListsProvider =
    StreamNotifierProvider<ShoppingListsNotifier, List<ShoppingListEntity>>(
  ShoppingListsNotifier.new,
);

class ShoppingListsNotifier extends StreamNotifier<List<ShoppingListEntity>> {
  @override
  Stream<List<ShoppingListEntity>> build() =>
      ref.watch(watchShoppingListsUseCaseProvider).call();

  Future<Either<Failure, int>> createList(String name) {
    return ref.read(createShoppingListUseCaseProvider).call(name);
  }

  Future<Either<Failure, Unit>> deleteList(int id) {
    return ref.read(deleteShoppingListUseCaseProvider).call(id);
  }

  Future<Either<Failure, Unit>> renameList(
      ShoppingListEntity list, String newName) {
    return ref.read(renameShoppingListUseCaseProvider).call(list, newName);
  }
}

// ── Shopping list detail notifier (per-list, family) ─────────────────────────

/// Streams a single list with its items. Auto-disposed when no longer needed.
final shoppingListDetailProvider = StreamNotifierProvider.autoDispose
    .family<ShoppingListDetailNotifier, ShoppingListEntity?, int>(
  ShoppingListDetailNotifier.new,
);

class ShoppingListDetailNotifier
    extends AutoDisposeFamilyStreamNotifier<ShoppingListEntity?, int> {
  @override
  Stream<ShoppingListEntity?> build(int arg) =>
      ref.watch(watchShoppingListUseCaseProvider).call(arg);

  Future<Either<Failure, int>> addItem({
    required String name,
    double quantity = 1.0,
    String unit = 'pcs',
    int? productId,
    int? categoryId,
  }) {
    return ref.read(addItemToListUseCaseProvider).call(
          listId: arg,
          name: name,
          quantity: quantity,
          unit: unit,
          productId: productId,
          categoryId: categoryId,
        );
  }

  Future<Either<Failure, Unit>> removeItem(int itemId) {
    return ref.read(removeItemFromListUseCaseProvider).call(itemId);
  }

  Future<Either<Failure, Unit>> toggleChecked(int itemId) {
    return ref.read(toggleItemCheckedUseCaseProvider).call(itemId);
  }
}
