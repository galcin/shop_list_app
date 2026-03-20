import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final int id;
  final String name;
  final String? photo;
  final String? colorHex;
  final String? iconName;

  /// Asset image filename, e.g. 'fruits_category.png'.
  /// When non-null the UI renders this image instead of the emoji.
  final String? imageName;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductCategory({
    required this.id,
    required this.name,
    this.photo,
    this.colorHex,
    this.iconName,
    this.imageName,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  ProductCategory copyWith({
    int? id,
    String? name,
    String? photo,
    String? colorHex,
    String? iconName,
    String? imageName,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      imageName: imageName ?? this.imageName,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        photo,
        colorHex,
        iconName,
        imageName,
        sortOrder,
        createdAt,
        updatedAt
      ];
}
