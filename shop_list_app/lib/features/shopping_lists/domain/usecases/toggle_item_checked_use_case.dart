import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class ToggleItemCheckedUseCase {
  ToggleItemCheckedUseCase(this._repository);
  final IShoppingListRepository _repository;

  Future<Either<Failure, Unit>> call(int itemId) async {
    try {
      await _repository.toggleItemChecked(itemId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
