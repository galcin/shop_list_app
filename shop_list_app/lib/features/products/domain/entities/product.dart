import 'package:shop_list_app/core/constants/units.dart';

/// Catalogue product: describes *what* something is, not how much of it the
/// user has (that belongs to pantry items and shopping items).
class Product {
  final int? id;
  final String? name;

  /// Unit suggested when the product is added to a list or recipe.
  final String defaultUnit;

  /// Emoji, `assets/...` path or local file path.
  final String? photo;

  /// Alternative names used for matching free text to this product.
  final List<String> aliases;
  final int? productCategoryId;

  /// `true` for catalogue rows shipped with the app.
  final bool isBuiltIn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    this.name,
    this.defaultUnit = Units.pcs,
    this.photo,
    this.aliases = const [],
    this.productCategoryId,
    this.isBuiltIn = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasPhoto => photo != null && photo!.trim().isNotEmpty;

  factory Product.fromMap(Map<String, dynamic> json) {
    final rawAliases = json['aliases'];
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
      defaultUnit: Units.normalize(
          json['defaultUnit'] as String? ?? json['units'] as String?),
      photo: json['photo'] as String?,
      aliases: rawAliases is List
          ? rawAliases.map((e) => e.toString()).toList()
          : rawAliases is String && rawAliases.isNotEmpty
              ? rawAliases.split('|')
              : const [],
      productCategoryId: json['productCategoryId'] as int?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'defaultUnit': defaultUnit,
        'photo': photo,
        'aliases': aliases,
        'productCategoryId': productCategoryId,
        'isBuiltIn': isBuiltIn,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Product copyWith({
    int? id,
    String? name,
    String? defaultUnit,
    String? photo,
    List<String>? aliases,
    int? productCategoryId,
    bool? isBuiltIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        defaultUnit: defaultUnit ?? this.defaultUnit,
        photo: photo ?? this.photo,
        aliases: aliases ?? this.aliases,
        productCategoryId: productCategoryId ?? this.productCategoryId,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
