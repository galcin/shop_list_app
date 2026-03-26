import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';

abstract class IShoppingListRepository {
  /// Stream of all non-deleted lists, ordered by [createdAt] desc.
  Stream<List<ShoppingListEntity>> watchAll();

  /// Stream of a single list with its items.
  Stream<ShoppingListEntity?> watchById(int id);

  /// Insert or update a list. Returns the saved row id.
  Future<int> save(ShoppingListEntity list);

  /// Soft-delete a list (sets [isDeleted] = true).
  Future<void> delete(int id);

  // ── Item operations ────────────────────────────────────────────────────────

  /// Add an item to a list. Returns the new item id.
  Future<int> addItem(ShoppingItemEntity item);

  /// Remove a single item.
  Future<void> removeItem(int itemId);

  /// Update an existing item.
  Future<void> updateItem(ShoppingItemEntity item);

  /// Toggle the [isChecked] flag of a single item.
  Future<void> toggleItemChecked(int itemId);

  /// Returns all items for a list grouped by [categoryId].
  Future<Map<int?, List<ShoppingItemEntity>>> getItemsGroupedByCategory(
      int listId);
}
