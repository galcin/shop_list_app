import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/database/app_database.dart' hide PantryItem;
import 'package:shop_list_app/features/pantry/data/repositories/pantry_repository.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/add_pantry_item_usecase.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/complete_shopping_list_usecase.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/delete_pantry_item_usecase.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/update_pantry_item_quantity_usecase.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/watch_expiring_soon_usecase.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/watch_pantry_items_usecase.dart';
import 'package:shop_list_app/features/pantry/presentation/state/pantry_notifier.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';

// Infrastructure Providers
final pantryRepositoryProvider = Provider<IPantryRepository>((ref) {
  return PantryRepository(AppDatabase.instance);
});

// Use Case Providers
final watchPantryItemsUseCaseProvider =
    Provider<WatchPantryItemsUseCase>((ref) {
  return WatchPantryItemsUseCase(ref.watch(pantryRepositoryProvider));
});

final addPantryItemUseCaseProvider = Provider<AddPantryItemUseCase>((ref) {
  return AddPantryItemUseCase(ref.watch(pantryRepositoryProvider));
});

final deletePantryItemUseCaseProvider =
    Provider<DeletePantryItemUseCase>((ref) {
  return DeletePantryItemUseCase(ref.watch(pantryRepositoryProvider));
});

final updatePantryItemQuantityUseCaseProvider =
    Provider<UpdatePantryItemQuantityUseCase>((ref) {
  return UpdatePantryItemQuantityUseCase(ref.watch(pantryRepositoryProvider));
});

final watchExpiringSoonUseCaseProvider =
    Provider<WatchExpiringSoonUseCase>((ref) {
  return WatchExpiringSoonUseCase(ref.watch(pantryRepositoryProvider));
});

final completeShoppingListUseCaseProvider =
    Provider<CompleteShoppingListUseCase>((ref) {
  return CompleteShoppingListUseCase(
    ref.watch(pantryRepositoryProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(productCategoryRepositoryProvider),
  );
});

// UI State Providers
final pantryFilterProvider = StateProvider.autoDispose<String>((ref) => 'all');
final pantrySearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

// Async Notifier Provider for pantry items
final pantryItemsProvider =
    AsyncNotifierProvider<PantryNotifier, List<PantryItem>>(
  PantryNotifier.new,
);

// Derived provider: filtered & searched pantry items
final filteredPantryItemsProvider =
    Provider.autoDispose<List<PantryItem>>((ref) {
  final asyncItems = ref.watch(pantryItemsProvider);
  final searchQuery = ref.watch(pantrySearchQueryProvider);
  final filter = ref.watch(pantryFilterProvider);

  return asyncItems.maybeWhen(
    data: (items) {
      var filtered = items;

      // Apply filter
      if (filter == 'expiring') {
        filtered = items
            .where((item) => item.expiryStatus == 'expiring-soon')
            .toList();
      } else if (filter == 'expired') {
        filtered = items.where((item) => item.isExpired).toList();
      } else if (filter == 'fresh') {
        filtered = items.where((item) => item.expiryStatus == 'fresh').toList();
      }

      // Apply search
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      return filtered;
    },
    orElse: () => [],
  );
});

// Derived provider: items grouped by category
final groupedPantryItemsProvider =
    Provider.autoDispose<Map<int, List<PantryItem>>>((ref) {
  final items = ref.watch(filteredPantryItemsProvider);

  final grouped = <int, List<PantryItem>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.categoryId, () => []).add(item);
  }

  return grouped;
});

// Derived provider: count of expiring items for badge
final expiringSoonCountProvider = Provider.autoDispose<int>((ref) {
  final items = ref.watch(pantryItemsProvider);
  return items.maybeWhen(
    data: (pantryItems) => pantryItems
        .where((item) => item.expiryStatus == 'expiring-soon' || item.isExpired)
        .length,
    orElse: () => 0,
  );
});
