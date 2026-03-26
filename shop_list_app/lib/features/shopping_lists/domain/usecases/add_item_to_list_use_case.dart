import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class AddItemToListUseCase {
  AddItemToListUseCase(this._repository);
  final IShoppingListRepository _repository;

  Future<Either<Failure, int>> call({
    required int listId,
    required String name,
    double quantity = 1.0,
    String unit = 'pcs',
    int? productId,
    int? categoryId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure('Item name must not be empty.'));
    }
    try {
      final id = await _repository.addItem(
        ShoppingItemEntity(
          listId: listId,
          productId: productId,
          name: trimmed,
          quantity: quantity,
          unit: unit,
          categoryId: categoryId,
          createdAt: DateTime.now(),
        ),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
