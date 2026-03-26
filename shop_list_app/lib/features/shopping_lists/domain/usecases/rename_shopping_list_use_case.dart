import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class RenameShoppingListUseCase {
  RenameShoppingListUseCase(this._repository);
  final IShoppingListRepository _repository;

  Future<Either<Failure, Unit>> call(
      ShoppingListEntity list, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure('List name must not be empty.'));
    }
    try {
      await _repository.save(list.copyWith(name: trimmed));
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
