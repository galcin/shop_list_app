// ignore_for_file: avoid_print
//
// One-off converter: upgrades the pre-v11 recipes.json format
// (ingredients as {name, quantity: "2", unit}) to the seed format
// (ingredients as {product, name?, quantity: 2, unit, note?}, plus a stable
// `key`). Ingredient names are resolved against products.json by name and
// alias; anything that cannot be resolved is left as `product: <name>` so
// validate_seed.dart reports it.
//
// Run from the project root:
//
//   dart run tool/seed/convert_legacy_recipes.dart [--in path] [--out path]
import 'dart:convert';
import 'dart:io';

import 'package:shop_list_app/core/constants/units.dart';
import 'package:shop_list_app/core/database/seeder/seed_data.dart';

Future<void> main(List<String> args) async {
  var inPath = SeedPaths.recipes;
  var outPath = SeedPaths.recipes;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--in' && i + 1 < args.length) inPath = args[++i];
    if (args[i] == '--out' && i + 1 < args.length) outPath = args[++i];
  }

  final products =
      SeedProduct.parseList(await File(SeedPaths.products).readAsString());
  final index = SeedProductIndex(products);
  final raw = jsonDecode(await File(inPath).readAsString()) as List<dynamic>;

  var unresolved = 0;
  final out = <Map<String, dynamic>>[];
  for (final entry in raw) {
    final map = Map<String, dynamic>.from(entry as Map);
    final name = (map['name'] as String).trim();
    final ingredients = <Map<String, dynamic>>[];
    for (final rawIng in (map['ingredients'] as List<dynamic>? ?? const [])) {
      final ing = Map<String, dynamic>.from(rawIng as Map);
      // Already converted?
      if (ing.containsKey('product')) {
        ingredients.add(ing);
        continue;
      }
      final legacyName = (ing['name'] as String? ?? '').trim();
      final rawQty = (ing['quantity'] ?? '').toString().trim();
      final qty = double.tryParse(rawQty.replaceAll(',', '.'));
      final unit = Units.normalize(ing['unit'] as String?);
      final product = index.resolve(legacyName);
      if (product == null) unresolved++;

      final converted = <String, dynamic>{
        'product': product?.name ?? legacyName,
        if (product != null &&
            normalizeSeedName(product.name) != normalizeSeedName(legacyName))
          'name': legacyName,
        if (qty != null) 'quantity': qty == qty.roundToDouble() ? qty.toInt() : qty,
        if (qty != null && unit.isNotEmpty) 'unit': unit,
        if (qty == null && rawQty.isNotEmpty) 'note': rawQty,
      };
      ingredients.add(converted);
    }

    out.add({
      'key': (map['key'] as String?) ?? SeedRecipe.slugify(name),
      'name': name,
      'category': map['category'] ?? 'Main Courses',
      if (map['description'] != null) 'description': map['description'],
      'instructions': map['instructions'] is List
          ? map['instructions']
          : (map['instructions'] as String? ?? '')
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .toList(),
      if (map['prepTime'] != null) 'prepTime': map['prepTime'],
      if (map['cookTime'] != null) 'cookTime': map['cookTime'],
      if (map['servings'] != null) 'servings': map['servings'],
      if (map['tags'] != null) 'tags': map['tags'],
      if (map['imageUrl'] != null) 'imageUrl': map['imageUrl'],
      'ingredients': ingredients,
    });
  }

  await File(outPath).writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(out)}\n');
  print('Converted ${out.length} recipes -> $outPath '
      '($unresolved unresolved ingredient lines)');
}
