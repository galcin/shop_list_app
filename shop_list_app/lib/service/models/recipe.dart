class Recipe {
  int? id;
  String? name;
  String? photo;
  String? description;
  int? foodCategoryId;
  String? foodCategory;

  Recipe(
      {this.name, this.photo, this.description, this.foodCategoryId, this.id});

  Recipe.fromMap(Map<String, dynamic> json) {
    this.name = json["name"];
    this.photo = json["photo"];
    this.description = json["description"];
    this.id = json["id"];
    this.foodCategoryId = json["foodCategoryId"];
    this.foodCategory = json["foodCategory"];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'description': description,
      'foodCategoryId': foodCategoryId,
      'foodCategory': foodCategory
    };
  }
}
