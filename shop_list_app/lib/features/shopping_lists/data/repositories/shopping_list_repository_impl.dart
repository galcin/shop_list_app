import 'package:shop_list_app/features/shopping_lists/data/datasources/shopping_list_data_source.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements IShoppingListRepository {
  ShoppingListRepositoryImpl(this._dataSource);

  final ShoppingListDataSource _dataSource;

  @override
  Stream<List<ShoppingListEntity>> watchAll() => _dataSource.watchAll();

  @override
  Stream<ShoppingListEntity?> watchById(int id) => _dataSource.watchById(id);

  @override
  Future<int> save(ShoppingListEntity list) => _dataSource.saveList(list);

  @override
  Future<void> delete(int id) => _dataSource.softDeleteList(id);

  @override
  Future<int> addItem(ShoppingItemEntity item) => _dataSource.addItem(item);

  @override
  Future<void> removeItem(int itemId) => _dataSource.removeItem(itemId);

  @override
  Future<void> updateItem(ShoppingItemEntity item) =>
      _dataSource.updateItem(item);

  @override
  Future<void> toggleItemChecked(int itemId) =>
      _dataSource.toggleItemChecked(itemId);

  @override
  Future<Map<int?, List<ShoppingItemEntity>>> getItemsGroupedByCategory(
          int listId) =>
      _dataSource.getItemsGroupedByCategory(listId);
}
