import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_list_entity.dart';
import 'package:shop_list_app/features/shopping_lists/domain/repositories/i_shopping_list_repository.dart';

class CreateShoppingListUseCase {
  CreateShoppingListUseCase(this._repository);
  final IShoppingListRepository _repository;

  Future<Either<Failure, int>> call(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure('List name must not be empty.'));
    }
    try {
      final id = await _repository.save(
        ShoppingListEntity(name: trimmed, createdAt: DateTime.now()),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
