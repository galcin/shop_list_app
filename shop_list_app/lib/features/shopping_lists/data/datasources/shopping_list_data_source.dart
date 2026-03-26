import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';

/// Drift-backed data source for all shopping list operations.
class ShoppingListDataSource {
  ShoppingListDataSource(this._db);

  final AppDatabase _db;

  // ── Lists ──────────────────────────────────────────────────────────────────

  Stream<List<ShoppingListEntity>> watchAll() {
    final listsStream = (_db.select(_db.shoppingLists)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();

    return listsStream.asyncMap((rows) async {
      final futures = rows.map((row) async {
        final items = await _itemsForList(row.id);
        return _listFromRow(row, items);
      });
      return Future.wait(futures);
    });
  }

  Stream<ShoppingListEntity?> watchById(int id) {
    final listStream = (_db.select(_db.shoppingLists)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .watchSingleOrNull();

    return listStream.asyncMap((row) async {
      if (row == null) return null;
      final items = await _itemsForList(row.id);
      return _listFromRow(row, items);
    });
  }

  Future<int> saveList(ShoppingListEntity list) async {
    if (list.id != null) {
      // Update
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(list.id!)))
          .write(ShoppingListsCompanion(
        name: Value(list.name),
        updatedAt: Value(DateTime.now()),
      ));
      return list.id!;
    } else {
      // Insert
      return _db.into(_db.shoppingLists).insert(
            ShoppingListsCompanion.insert(name: list.name),
          );
    }
  }

  Future<void> softDeleteList(int id) async {
    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(id)))
        .write(const ShoppingListsCompanion(
      isDeleted: Value(true),
      updatedAt: Value.absent(), // will use current time via trigger-like logic
    ));
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<int> addItem(ShoppingItemEntity item) {
    return _db.into(_db.shoppingItems).insert(
          ShoppingItemsCompanion.insert(
            listId: item.listId,
            name: item.name,
            productId: Value(item.productId),
            quantity: Value(item.quantity),
            unit: Value(item.unit),
            categoryId: Value(item.categoryId),
            sortOrder: Value(item.sortOrder),
          ),
        );
  }

  Future<void> removeItem(int itemId) async {
    await (_db.delete(_db.shoppingItems)..where((t) => t.id.equals(itemId)))
        .go();
  }

  Future<void> updateItem(ShoppingItemEntity item) async {
    if (item.id == null) return;
    await (_db.update(_db.shoppingItems)..where((t) => t.id.equals(item.id!)))
        .write(ShoppingItemsCompanion(
      name: Value(item.name),
      quantity: Value(item.quantity),
      unit: Value(item.unit),
      isChecked: Value(item.isChecked),
      categoryId: Value(item.categoryId),
      sortOrder: Value(item.sortOrder),
    ));
  }

  Future<void> toggleItemChecked(int itemId) async {
    // Read current value then flip it — optimistic local op.
    final row = await (_db.select(_db.shoppingItems)
          ..where((t) => t.id.equals(itemId)))
        .getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.shoppingItems)..where((t) => t.id.equals(itemId)))
        .write(ShoppingItemsCompanion(isChecked: Value(!row.isChecked)));
  }

  Future<Map<int?, List<ShoppingItemEntity>>> getItemsGroupedByCategory(
      int listId) async {
    final rows = await _itemsForList(listId);
    final map = <int?, List<ShoppingItemEntity>>{};
    for (final item in rows) {
      map.putIfAbsent(item.categoryId, () => []).add(item);
    }
    return map;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<List<ShoppingItemEntity>> _itemsForList(int listId) async {
    final rows = await (_db.select(_db.shoppingItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    return rows.map(_itemFromRow).toList();
  }

  ShoppingListEntity _listFromRow(
          ShoppingList row, List<ShoppingItemEntity> items) =>
      ShoppingListEntity(
        id: row.id,
        name: row.name,
        items: items,
        createdAt: row.createdAt,
      );

  ShoppingItemEntity _itemFromRow(ShoppingItem row) => ShoppingItemEntity(
        id: row.id,
        listId: row.listId,
        productId: row.productId,
        name: row.name,
        quantity: row.quantity,
        unit: row.unit,
        isChecked: row.isChecked,
        categoryId: row.categoryId,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
      );
}
