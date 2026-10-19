import 'package:shop_list_app/core/constants/units.dart';
import 'package:shop_list_app/core/utils/number_utils.dart';

/// A single ingredient line within a recipe.
class Ingredient {
  final int? id;

  /// Catalogue product this line refers to. Null for free-text ingredients.
  final int? productId;

  /// Display name (defaults to the product name).
  final String name;

  /// Null when the ingredient has no measurable amount ("to taste").
  final double? quantity;

  /// Canonical unit code from [Units]; empty when there is no unit.
  final String unit;

  /// Free text such as "to taste", "finely chopped".
  final String? note;

  const Ingredient({
    this.id,
    this.productId,
    required this.name,
    this.quantity,
    this.unit = Units.none,
    this.note,
  });

  /// `true` when the line has no measurable quantity (seasoning, garnish…).
  bool get isOptional => quantity == null;

  /// "2 pcs", "250 g", "1 clove", "to taste".
  String get quantityLabel {
    final qty = quantity;
    if (qty == null) return note ?? '';
    final number = NumberUtils.formatQuantity(qty);
    final unitLabel = Units.label(unit, qty);
    return unitLabel.isEmpty ? number : '$number $unitLabel';
  }

  /// Returns a copy with the quantity multiplied by [factor].
  Ingredient scale(double factor) {
    final qty = quantity;
    if (qty == null) return this;
    return copyWith(quantity: qty * factor);
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    final rawQty = map['quantity'];
    double? qty;
    if (rawQty is num) {
      qty = rawQty.toDouble();
    } else if (rawQty is String) {
      qty = double.tryParse(rawQty.replaceAll(',', '.'));
    }
    return Ingredient(
      id: map['id'] as int?,
      productId: map['productId'] as int?,
      name: map['name'] as String? ?? '',
      quantity: qty,
      unit: Units.normalize(map['unit'] as String?),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (productId != null) 'productId': productId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        if (note != null) 'note': note,
      };

  Ingredient copyWith({
    int? id,
    int? productId,
    bool clearProductId = false,
    String? name,
    double? quantity,
    bool clearQuantity = false,
    String? unit,
    String? note,
    bool clearNote = false,
  }) =>
      Ingredient(
        id: id ?? this.id,
        productId: clearProductId ? null : (productId ?? this.productId),
        name: name ?? this.name,
        quantity: clearQuantity ? null : (quantity ?? this.quantity),
        unit: unit ?? this.unit,
        note: clearNote ? null : (note ?? this.note),
      );

  @override
  String toString() => '$quantityLabel $name'.trim();
}

/// Core recipe domain entity.
class Recipe {
  final int? id;
  final String? name;
  final String? description;
  final String? category;

  /// Newline-separated cooking steps stored as a single string.
  final String? instructions;
  final int? prepTime; // minutes
  final int? cookTime; // minutes
  final int? servings;
  final bool favorite;
  final String? imageUrl;
  final double? rating;
  final List<String> tags;
  final List<Ingredient> ingredients;

  /// `true` for recipes shipped with the app and not yet edited by the user.
  final bool isBuiltIn;

  /// Stable key from the seed file; null for user recipes.
  final String? seedKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Recipe({
    this.id,
    this.name,
    this.description,
    this.category,
    this.instructions,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.favorite = false,
    this.imageUrl,
    this.rating,
    this.tags = const [],
    this.ingredients = const [],
    this.isBuiltIn = false,
    this.seedKey,
    this.createdAt,
    this.updatedAt,
  });

  // ── Computed properties ───────────────────────────────────────────────────

  int get totalTime => (prepTime ?? 0) + (cookTime ?? 0);

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

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
      ingredients: ingredients.map((i) => i.scale(factor)).toList(),
    );
  }

  // ── Serialisation (export / import) ───────────────────────────────────────

  factory Recipe.fromMap(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final rawTags = json['tags'];
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      instructions: json['instructions'] as String?,
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      favorite: json['favorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      tags: rawTags is List ? rawTags.map((e) => e.toString()).toList() : [],
      ingredients: rawIngredients is List
          ? rawIngredients
              .map((e) => Ingredient.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      seedKey: json['seedKey'] as String?,
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
        'description': description,
        'category': category,
        'instructions': instructions,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'servings': servings,
        'favorite': favorite,
        'imageUrl': imageUrl,
        'rating': rating,
        'tags': tags,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'isBuiltIn': isBuiltIn,
        'seedKey': seedKey,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// Alias required by GoRouter for `extra` serialisation.
  Map<String, dynamic> toJson() => toMap();

  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    bool? favorite,
    String? imageUrl,
    double? rating,
    List<String>? tags,
    List<Ingredient>? ingredients,
    bool? isBuiltIn,
    String? seedKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        instructions: instructions ?? this.instructions,
        prepTime: prepTime ?? this.prepTime,
        cookTime: cookTime ?? this.cookTime,
        servings: servings ?? this.servings,
        favorite: favorite ?? this.favorite,
        imageUrl: imageUrl ?? this.imageUrl,
        rating: rating ?? this.rating,
        tags: tags ?? this.tags,
        ingredients: ingredients ?? this.ingredients,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        seedKey: seedKey ?? this.seedKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
