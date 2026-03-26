import 'package:shop_list_app/features/shopping_lists/domain/entities/shopping_item_entity.dart';

class ShoppingListEntity {
  final int? id;
  final String name;
  final List<ShoppingItemEntity> items;
  final DateTime createdAt;

  const ShoppingListEntity({
    this.id,
    required this.name,
    this.items = const [],
    required this.createdAt,
  });

  /// Percentage of checked items (0–1 range).
  double get completionPercent {
    if (items.isEmpty) return 0;
    return items.where((i) => i.isChecked).length / items.length;
  }

  int get checkedCount => items.where((i) => i.isChecked).length;

  ShoppingListEntity copyWith({
    int? id,
    String? name,
    List<ShoppingItemEntity>? items,
    DateTime? createdAt,
  }) =>
      ShoppingListEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
      );
}
