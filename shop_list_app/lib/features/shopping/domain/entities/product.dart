class Product {
  final int? id;
  final String? name;
  final double? quantity;
  final String? units;
  final String? photo;
  final DateTime? expirationDate;
  final int? productCategoryId;

  Product({
    this.id,
    this.name,
    this.quantity,
    this.units,
    this.photo,
    this.expirationDate,
    this.productCategoryId,
  });

  factory Product.fromMap(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
      quantity: json['quantity'] as double?,
      units: json['units'] as String?,
      photo: json['photo'] as String?,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      productCategoryId: json['productCategoryId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'units': units,
      'photo': photo,
      'expirationDate': expirationDate?.toIso8601String(),
      'productCategoryId': productCategoryId,
    };
  }
}
