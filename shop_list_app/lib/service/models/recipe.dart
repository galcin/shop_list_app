class Recipe {
  final int? id;
  final String? name;
  final String? instructions;
  final int? prepTime;
  final bool? favorite;

  Recipe({
    this.id,
    this.name,
    this.instructions,
    this.prepTime,
    this.favorite,
  });

  factory Recipe.fromMap(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String?,
      instructions: json['instructions'] as String?,
      prepTime: json['prepTime'] as int?,
      favorite: json['favorite'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'prepTime': prepTime,
      'favorite': favorite,
    };
  }
}
