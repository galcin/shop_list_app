import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';

/// Use case to convert shopping list items to pantry items.
/// For each shopping item:
/// - If a pantry item with the same name exists in the same category, add to quantity
/// - Otherwise, create a new pantry item
class CompleteShoppingListUseCase {
  final IPantryRepository _repository;

  CompleteShoppingListUseCase(this._repository);

  Future<Either<Failure, int>> call(
    List<ShoppingItemEntity> items,
  ) async {
    try {
      if (items.isEmpty) {
        return const Right(0);
      }

      int addedCount = 0;

      // Get all existing pantry items to check for duplicates
      final existingItems = await _repository.getAll();

      for (final item in items) {
        // Find if an item with the same name and category already exists
        final matchingItems = existingItems.where(
          (pItem) =>
              pItem.name.toLowerCase() == item.name.toLowerCase() &&
              pItem.categoryId == (item.categoryId ?? 1),
        );
        final existingItem = matchingItems.isEmpty ? null : matchingItems.first;

        if (existingItem != null) {
          // Update existing item: add quantities
          final updated = existingItem.copyWith(
            quantity: existingItem.quantity + item.quantity,
            updatedAt: DateTime.now(),
          );
          await _repository.update(updated);
          addedCount++;
        } else {
          // Create new pantry item
          final newItem = PantryItem(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            categoryId: item.categoryId ?? 1,
            productId: item.productId,
            expiryDate: null,
            purchasedDate: DateTime.now(),
            location: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSynced: false,
            isDeleted: false,
          );
          final id = await _repository.save(newItem);
          if (id > 0) {
            addedCount++;
          }
        }
      }

      return Right(addedCount);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to complete shopping list: $e'),
      );
    }
  }
}
