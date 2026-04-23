import 'dart:convert';

/// A single ingredient item within a recipe.
class Ingredient {
  final String name;
  final String quantity;
  final String unit;

  const Ingredient({
    required this.name,
    required this.quantity,
    this.unit = '',
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        name: map['name'] as String? ?? '',
        quantity: map['quantity'] as String? ?? '',
        unit: map['unit'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  /// Returns a new [Ingredient] with quantity scaled by [factor].
  Ingredient scale(double factor) {
    final qty = double.tryParse(quantity);
    if (qty != null) {
      return Ingredient(
          name: name, quantity: _formatNumber(qty * factor), unit: unit);
    }
    return this;
  }

  static String _formatNumber(double n) {
    if (n == n.truncateToDouble()) return n.truncate().toString();
    final s = n.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  String toString() => '$quantity${unit.isNotEmpty ? ' $unit' : ''} $name';
}

/// Core recipe domain entity.
class Recipe {
  final int? id;
  final String? name;
  final String? description;

  /// Newline-separated cooking steps stored as a single string.
  final String? instructions;
  final int? prepTime; // minutes
  final int? cookTime; // minutes
  final int? servings;
  final bool? favorite;
  final String? imageUrl;
  final double? rating;
  final List<String>? tags;
  final List<Ingredient>? ingredients;

  const Recipe({
    this.id,
    this.name,
    this.description,
    this.instructions,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.favorite,
    this.imageUrl,
    this.rating,
    this.tags,
    this.ingredients,
  });

  // ── Computed properties ───────────────────────────────────────────────────

  int get totalTime => (prepTime ?? 0) + (cookTime ?? 0);

  List<String> get instructionSteps => (instructions ?? '')
      .split('\n')
      .where((s) => s.trim().isNotEmpty)
      .toList();

  // ── Domain behaviour ──────────────────────────────────────────────────────

  /// Returns a scaled copy of this recipe for [newServings].
  /// Scaling is session-only — not persisted to DB.
  Recipe scaleServings(int newServings) {
    if (servings == null || servings == 0 || newServings < 1) return this;
    final factor = newServings / servings!;
    return copyWith(
      servings: newServings,
      ingredients: ingredients?.map((i) => i.scale(factor)).toList(),
    );
  }

  // ── Factory / serialisation ───────────────────────────────────────────────

  factory Recipe.fromMap(Map<String, dynamic> json) {
    List<Ingredient>? ingredients;
    if (json['ingredientsJson'] != null) {
      final raw =
          jsonDecode(json['ingredientsJson'] as String) as List<dynamic>;
      ingredients = raw
          .map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    List<String>? tags;
    if (json['tagsJson'] != null) {
      final raw = jsonDecode(json['tagsJson'] as String) as List<dynamic>;
      tags = raw.cast<String>();
    }
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      prepTime: json['prepTime'] as int?,
      cookTime: json['cookTime'] as int?,
      servings: json['servings'] as int?,
      favorite: json['favorite'] as bool?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      tags: tags,
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'instructions': instructions,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'servings': servings,
        'favorite': favorite,
        'imageUrl': imageUrl,
        'rating': rating,
        'tagsJson': tags != null ? jsonEncode(tags) : null,
        'ingredientsJson': ingredients != null
            ? jsonEncode(ingredients!.map((i) => i.toMap()).toList())
            : null,
      };

  /// Alias required by GoRouter for `extra` serialisation.
  Map<String, dynamic> toJson() => toMap();

  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    String? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    bool? favorite,
    String? imageUrl,
    double? rating,
    List<String>? tags,
    List<Ingredient>? ingredients,
  }) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        instructions: instructions ?? this.instructions,
        prepTime: prepTime ?? this.prepTime,
        cookTime: cookTime ?? this.cookTime,
        servings: servings ?? this.servings,
        favorite: favorite ?? this.favorite,
        imageUrl: imageUrl ?? this.imageUrl,
        rating: rating ?? this.rating,
        tags: tags ?? this.tags,
        ingredients: ingredients ?? this.ingredients,
      );
}
