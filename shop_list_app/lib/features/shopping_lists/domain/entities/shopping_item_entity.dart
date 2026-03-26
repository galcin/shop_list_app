class ShoppingItemEntity {
  final int? id;
  final int listId;
  final int? productId;
  final String name;
  final double quantity;
  final String unit;
  final bool isChecked;
  final int? categoryId;
  final int sortOrder;
  final DateTime createdAt;

  const ShoppingItemEntity({
    this.id,
    required this.listId,
    this.productId,
    required this.name,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.isChecked = false,
    this.categoryId,
    this.sortOrder = 0,
    required this.createdAt,
  });

  ShoppingItemEntity toggleChecked() => copyWith(isChecked: !isChecked);

  ShoppingItemEntity copyWith({
    int? id,
    int? listId,
    int? productId,
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
    int? categoryId,
    int? sortOrder,
    DateTime? createdAt,
  }) =>
      ShoppingItemEntity(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        isChecked: isChecked ?? this.isChecked,
        categoryId: categoryId ?? this.categoryId,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
}
