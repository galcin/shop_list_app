import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';

class PantryNotifier extends AsyncNotifier<List<PantryItem>> {
  @override
  Future<List<PantryItem>> build() async {
    try {
      AppLogger.instance.info('[Pantry] build() starting...');
      final items = await ref.read(pantryRepositoryProvider).getAll();
      AppLogger.instance
          .info('[Pantry] build() completed with ${items.length} items');
      return items;
    } catch (e, st) {
      AppLogger.instance
          .error('[Pantry] build() failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Add a new pantry item
  Future<void> addItem({
    required String name,
    required double quantity,
    required String unit,
    required int categoryId,
    int? productId,
    DateTime? expiryDate,
    String? location,
  }) async {
    final result = await ref.read(addPantryItemUseCaseProvider).call(
          name: name,
          quantity: quantity,
          unit: unit,
          categoryId: categoryId,
          productId: productId,
          expiryDate: expiryDate,
          location: location,
        );

    if (result.isRight()) {
      // Success - refresh the list
      state = await AsyncValue.guard(_fetchAll);
      AppLogger.instance.info('[Pantry] Item added and list refreshed');
    } else {
      // Error
      final failure = result.fold((f) => f, (r) => null);
      AppLogger.instance.error('[Pantry] Failed to add item: $failure');
      throw Exception(failure.toString());
    }
  }

  /// Delete a pantry item
  Future<void> deleteItem(int id) async {
    final result = await ref.read(deletePantryItemUseCaseProvider).call(id);

    if (result.isRight()) {
      // Success - refresh the list
      state = await AsyncValue.guard(_fetchAll);
      AppLogger.instance.info('[Pantry] Item deleted and list refreshed');
    } else {
      // Error
      final failure = result.fold((f) => f, (r) => null);
      AppLogger.instance.error('[Pantry] Failed to delete item: $failure');
      throw Exception(failure.toString());
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(int id, double newQuantity) async {
    final result = await ref
        .read(updatePantryItemQuantityUseCaseProvider)
        .call(id: id, newQuantity: newQuantity);

    if (result.isRight()) {
      // Success - refresh the list
      state = await AsyncValue.guard(_fetchAll);
      AppLogger.instance.info('[Pantry] Quantity updated and list refreshed');
    } else {
      // Error
      final failure = result.fold((f) => f, (r) => null);
      AppLogger.instance.error('[Pantry] Failed to update quantity: $failure');
      throw Exception(failure.toString());
    }
  }

  Future<List<PantryItem>> _fetchAll() async {
    return await ref.read(pantryRepositoryProvider).getAll();
  }
}
