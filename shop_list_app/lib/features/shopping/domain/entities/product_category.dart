class ProductCategory {
  final int id;
  final String name;
  final String? photo;

  ProductCategory({
    required this.id,
    required this.name,
    this.photo,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
    };
  }
}
