import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart'
    as model;
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';

class PantryRepository implements IPantryRepository {
  final AppDatabase _database;

  PantryRepository(this._database);

  @override
  Stream<List<model.PantryItem>> watchAll() {
    return (_database.select(_database.pantryItems)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.categoryId)]))
        .watch()
        .map((rows) => rows.map(_pantryItemFromRow).toList());
  }

  @override
  Stream<List<model.PantryItem>> watchExpiringSoon({required int days}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    return (_database.select(_database.pantryItems)
          ..where((tbl) =>
              tbl.isDeleted.equals(false) &
              tbl.expiryDate.isBetweenValues(now, threshold))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.expiryDate)]))
        .watch()
        .map((rows) => rows.map(_pantryItemFromRow).toList());
  }

  @override
  Future<List<model.PantryItem>> getAll() async {
    try {
      AppLogger.instance.info('[PantryRepo] getAll() starting...');
      AppLogger.instance
          .info('[PantryRepo] Building select query for pantryItems...');
      final query = _database.select(_database.pantryItems)
        ..where((tbl) => tbl.isDeleted.equals(false));
      AppLogger.instance.info('[PantryRepo] Query built, executing .get()...');
      final rows = await query.get();
      AppLogger.instance
          .info('[PantryRepo] getAll() returned ${rows.length} rows');
      final result = rows.map(_pantryItemFromRow).toList();
      AppLogger.instance.info(
          '[PantryRepo] Mapping complete, returning ${result.length} items');
      return result;
    } catch (e, st) {
      AppLogger.instance
          .error('[PantryRepo] getAll() failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> save(model.PantryItem item) async {
    try {
      final id = await _database.into(_database.pantryItems).insert(
            PantryItemsCompanion(
              productId: Value(item.productId),
              name: Value(item.name),
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              categoryId: Value(item.categoryId),
              expiryDate: Value(item.expiryDate),
              purchasedDate: Value(item.purchasedDate),
              location: Value(item.location),
              createdAt: Value(item.createdAt),
              updatedAt: Value(item.updatedAt),
              isSynced: Value(item.isSynced),
              isDeleted: Value(item.isDeleted),
            ),
          );
      return id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> update(model.PantryItem item) async {
    try {
      if (item.id == null) return false;

      final success = await _database.update(_database.pantryItems).replace(
            PantryItemsCompanion(
              id: Value(item.id!),
              productId: Value(item.productId),
              name: Value(item.name),
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              categoryId: Value(item.categoryId),
              expiryDate: Value(item.expiryDate),
              purchasedDate: Value(item.purchasedDate),
              location: Value(item.location),
              createdAt: Value(item.createdAt),
              updatedAt: Value(DateTime.now()),
              isSynced: Value(item.isSynced),
              isDeleted: Value(item.isDeleted),
            ),
          );
      return success;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      await _database.update(_database.pantryItems).replace(
            PantryItemsCompanion(
              id: Value(id),
              isDeleted: const Value(true),
            ),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<model.PantryItem?> getById(int id) async {
    try {
      final row = await (_database.select(_database.pantryItems)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();
      return row != null ? _pantryItemFromRow(row) : null;
    } catch (e) {
      return null;
    }
  }

  model.PantryItem _pantryItemFromRow(PantryItem row) {
    return model.PantryItem(
      id: row.id,
      productId: row.productId,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      categoryId: row.categoryId,
      expiryDate: row.expiryDate,
      purchasedDate: row.purchasedDate,
      location: row.location,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
      isDeleted: row.isDeleted,
    );
  }
}
