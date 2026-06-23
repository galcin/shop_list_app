import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';

class WatchPantryItemsUseCase {
  final IPantryRepository _repository;

  WatchPantryItemsUseCase(this._repository);

  Stream<Either<Failure, List<PantryItem>>> call() {
    try {
      return _repository.watchAll().map((items) => Right(items));
    } catch (e) {
      return Stream.value(Left(DatabaseFailure(e.toString())));
    }
  }
}
