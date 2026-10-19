// Seed data models and parsers.
//
// Pure Dart (no Flutter imports) so the same code is shared by the app's
// SeedService and by the command line tools under `tool/seed/`.
import 'dart:convert';

import 'package:shop_list_app/core/constants/units.dart';

/// Paths of the bundled seed files, relative to the package root.
class SeedPaths {
  SeedPaths._();

  static const String manifest = 'assets/data/seed_manifest.json';
  static const String categories = 'assets/data/product_categories.json';
  static const String products = 'assets/data/products.json';
  static const String recipes = 'assets/data/recipes.json';
}

/// Normalises a product or ingredient name for lookups: lowercase, ASCII
/// letters and digits only, single spaces.
String normalizeSeedName(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class SeedManifest {
  const SeedManifest({
    required this.version,
    this.recipeCount,
    this.productCount,
    this.generatedAt,
  });

  final int version;
  final int? recipeCount;
  final int? productCount;
  final String? generatedAt;

  factory SeedManifest.fromJson(Map<String, dynamic> json) => SeedManifest(
        version: (json['version'] as num).toInt(),
        recipeCount: (json['recipeCount'] as num?)?.toInt(),
        productCount: (json['productCount'] as num?)?.toInt(),
        generatedAt: json['generatedAt'] as String?,
      );

  static SeedManifest parse(String source) =>
      SeedManifest.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class SeedCategory {
  const SeedCategory({
    required this.name,
    this.emoji,
    this.colorHex,
    this.imageName,
    this.sortOrder = 0,
  });

  final String name;
  final String? emoji;
  final String? colorHex;
  final String? imageName;
  final int sortOrder;

  factory SeedCategory.fromJson(Map<String, dynamic> json, int index) =>
      SeedCategory(
        name: (json['name'] as String).trim(),
        emoji: json['emoji'] as String?,
        colorHex: json['colorHex'] as String?,
        imageName: json['imageName'] as String?,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? index,
      );

  static List<SeedCategory> parseList(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    return [
      for (var i = 0; i < raw.length; i++)
        SeedCategory.fromJson(raw[i] as Map<String, dynamic>, i),
    ];
  }
}

class SeedProduct {
  const SeedProduct({
    required this.name,
    required this.category,
    this.unit = Units.pcs,
    this.emoji,
    this.image,
    this.aliases = const [],
  });

  final String name;
  final String category;
  final String unit;
  final String? emoji;

  /// Asset path, e.g. `assets/images/products/carrots.jpg`.
  final String? image;
  final List<String> aliases;

  /// Value stored in the `photo` column: image path wins over emoji.
  String? get photo => (image != null && image!.isNotEmpty) ? image : emoji;

  /// Lowercase names this product answers to, including its own name.
  Set<String> get lookupKeys => {
        normalizeSeedName(name),
        for (final a in aliases) normalizeSeedName(a),
      }..removeWhere((k) => k.isEmpty);

  factory SeedProduct.fromJson(Map<String, dynamic> json) => SeedProduct(
        name: (json['name'] as String).trim(),
        category: (json['category'] as String).trim(),
        unit: Units.normalize(json['unit'] as String? ?? Units.pcs),
        emoji: json['emoji'] as String?,
        image: json['image'] as String?,
        aliases: (json['aliases'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  static List<SeedProduct> parseList(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    return raw
        .map((e) => SeedProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class SeedIngredient {
  const SeedIngredient({
    required this.product,
    this.name,
    this.quantity,
    this.unit = Units.none,
    this.note,
  });

  /// Catalogue product name (or alias) this line refers to.
  final String product;

  /// Optional display override, e.g. "Garlic (whole head)".
  final String? name;
  final double? quantity;
  final String unit;
  final String? note;

  String get displayName => (name != null && name!.trim().isNotEmpty)
      ? name!.trim()
      : product.trim();

  factory SeedIngredient.fromJson(Map<String, dynamic> json) {
    final rawQty = json['quantity'];
    double? qty;
    String? note = json['note'] as String?;
    if (rawQty is num) {
      qty = rawQty.toDouble();
    } else if (rawQty is String) {
      qty = double.tryParse(rawQty.replaceAll(',', '.'));
      if (qty == null && rawQty.trim().isNotEmpty) {
        note ??= rawQty.trim();
      }
    }
    return SeedIngredient(
      product: (json['product'] as String).trim(),
      name: json['name'] as String?,
      quantity: qty,
      unit: Units.normalize(json['unit'] as String?),
      note: note,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product,
        if (name != null) 'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit.isNotEmpty) 'unit': unit,
        if (note != null) 'note': note,
      };
}

class SeedRecipe {
  const SeedRecipe({
    required this.key,
    required this.name,
    required this.category,
    this.description,
    this.instructions = const [],
    this.prepTime,
    this.cookTime,
    this.servings,
    this.tags = const [],
    this.imageUrl,
    this.ingredients = const [],
  });

  final String key;
  final String name;
  final String category;
  final String? description;
  final List<String> instructions;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final List<String> tags;
  final String? imageUrl;
  final List<SeedIngredient> ingredients;

  factory SeedRecipe.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String).trim();
    final rawInstructions = json['instructions'];
    final instructions = rawInstructions is List
        ? rawInstructions.map((e) => e.toString()).toList()
        : rawInstructions is String
            ? rawInstructions
                .split('\n')
                .where((s) => s.trim().isNotEmpty)
                .toList()
            : const <String>[];
    return SeedRecipe(
      key: (json['key'] as String?)?.trim().isNotEmpty == true
          ? (json['key'] as String).trim()
          : slugify(name),
      name: name,
      category: (json['category'] as String? ?? 'Main Courses').trim(),
      description: json['description'] as String?,
      instructions: instructions,
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((e) => SeedIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'category': category,
        if (description != null) 'description': description,
        'instructions': instructions,
        if (prepTime != null) 'prepTime': prepTime,
        if (cookTime != null) 'cookTime': cookTime,
        if (servings != null) 'servings': servings,
        if (tags.isNotEmpty) 'tags': tags,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  static List<SeedRecipe> parseList(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    return raw
        .map((e) => SeedRecipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// "Egg Omelet" -> "egg-omelet". Same convention as the image file names.
  static String slugify(String input) {
    final lower = input.toLowerCase().trim();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
    return collapsed.replaceAll(RegExp(r'^-|-$'), '');
  }
}

/// Resolves ingredient product names to catalogue entries using names and
/// aliases. Shared by the seeder and the validation tool.
class SeedProductIndex {
  SeedProductIndex(Iterable<SeedProduct> products) {
    for (final p in products) {
      for (final key in p.lookupKeys) {
        _byKey.putIfAbsent(key, () => p);
      }
    }
  }

  final Map<String, SeedProduct> _byKey = {};

  SeedProduct? resolve(String name) {
    final key = normalizeSeedName(name);
    if (key.isEmpty) return null;
    final direct = _byKey[key];
    if (direct != null) return direct;
    // Tolerate a trailing plural "s" in either direction.
    if (key.endsWith('s')) {
      final singular = _byKey[key.substring(0, key.length - 1)];
      if (singular != null) return singular;
    }
    return _byKey['${key}s'];
  }
}
