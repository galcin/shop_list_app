import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class WatchShoppingListUseCase {
  WatchShoppingListUseCase(this._repository);
  final IShoppingListRepository _repository;

  Stream<ShoppingListEntity?> call(int id) => _repository.watchById(id);
}
