import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class WatchShoppingListsUseCase {
  WatchShoppingListsUseCase(this._repository);
  final IShoppingListRepository _repository;

  Stream<List<ShoppingListEntity>> call() => _repository.watchAll();
}
