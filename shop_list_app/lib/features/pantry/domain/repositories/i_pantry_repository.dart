import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';

abstract class IPantryRepository {
  /// Watch all pantry items (including deleted ones filtered by app logic)
  Stream<List<PantryItem>> watchAll();

  /// Watch items expiring within [days]
  Stream<List<PantryItem>> watchExpiringSoon({required int days});

  /// Get all pantry items as a future (one-time fetch)
  Future<List<PantryItem>> getAll();

  /// Add a new pantry item
  Future<int> save(PantryItem item);

  /// Update an existing pantry item
  Future<bool> update(PantryItem item);

  /// Delete a pantry item by id
  Future<bool> delete(int id);

  /// Get a single pantry item by id
  Future<PantryItem?> getById(int id);

  /// Permanently delete all pantry items
  Future<void> clearAll();
}
