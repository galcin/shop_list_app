// ignore_for_file: avoid_print
//
// Merges agent/human written batch files from tool/seed/batches/*.json into
// assets/data/recipes.json and assets/data/products.json.
//
//   * recipes: skipped when the key or (normalised) name already exists
//   * newProducts: skipped when the name or any alias already resolves to a
//     catalogue product; otherwise appended
//   * every merged ingredient's `product` is re-checked; unresolved ones are
//     reported (and left in place for validate_seed.dart to flag)
//
// Run from the project root:
//
//   dart run tool/seed/merge_batches.dart [--dry-run] [--only soups.json]
import 'dart:convert';
import 'dart:io';

import 'package:shop_list_app/core/database/seeder/seed_data.dart';

const _batchesDir = 'tool/seed/batches';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final onlyIdx = args.indexOf('--only');
  final only = onlyIdx >= 0 && onlyIdx + 1 < args.length ? args[onlyIdx + 1] : null;

  final recipesFile = File(SeedPaths.recipes);
  final productsFile = File(SeedPaths.products);
  final recipesRaw =
      (jsonDecode(await recipesFile.readAsString()) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
  final productsRaw =
      (jsonDecode(await productsFile.readAsString()) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  final products = productsRaw.map(SeedProduct.fromJson).toList();
  var index = SeedProductIndex(products);
  final recipeKeys = {for (final r in recipesRaw) r['key'] as String};
  final recipeNames = {
    for (final r in recipesRaw) normalizeSeedName(r['name'] as String),
  };

  final dir = Directory(_batchesDir);
  if (!dir.existsSync()) {
    print('No $_batchesDir directory.');
    return;
  }
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .where((f) => only == null || f.path.endsWith(only))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var addedRecipes = 0, skippedRecipes = 0, addedProducts = 0;
  final unresolved = <String, int>{};

  for (final file in files) {
    Map<String, dynamic> batch;
    try {
      batch = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      print('!! ${file.path}: invalid JSON ($e)');
      continue;
    }

    // New products first so the batch's own recipes can resolve them.
    for (final raw in (batch['newProducts'] as List<dynamic>? ?? const [])) {
      final map = Map<String, dynamic>.from(raw as Map);
      SeedProduct p;
      try {
        p = SeedProduct.fromJson(map);
      } catch (e) {
        print('!! ${file.path}: bad product $map ($e)');
        continue;
      }
      if (p.lookupKeys.any((k) => index.resolve(k) != null)) continue;
      productsRaw.add({
        'name': p.name,
        'category': p.category,
        'unit': p.unit,
        if (p.emoji != null) 'emoji': p.emoji,
        if (p.image != null) 'image': p.image,
        if (p.aliases.isNotEmpty) 'aliases': p.aliases,
      });
      products.add(p);
      index = SeedProductIndex(products);
      addedProducts++;
    }

    final batchCategory = batch['category'] as String?;
    for (final raw in (batch['recipes'] as List<dynamic>? ?? const [])) {
      final map = Map<String, dynamic>.from(raw as Map);
      SeedRecipe r;
      try {
        map['category'] ??= batchCategory;
        r = SeedRecipe.fromJson(map);
      } catch (e) {
        print('!! ${file.path}: bad recipe ${map['name']} ($e)');
        continue;
      }
      final nameKey = normalizeSeedName(r.name);
      if (recipeKeys.contains(r.key) || recipeNames.contains(nameKey)) {
        skippedRecipes++;
        continue;
      }
      for (final ing in r.ingredients) {
        if (index.resolve(ing.product) == null) {
          unresolved[ing.product] = (unresolved[ing.product] ?? 0) + 1;
        }
      }
      recipeKeys.add(r.key);
      recipeNames.add(nameKey);
      recipesRaw.add(r.toJson());
      addedRecipes++;
    }
    print('${file.path}: merged');
  }

  print('\nRecipes added: $addedRecipes (skipped $skippedRecipes duplicates)');
  print('Products added: $addedProducts');
  if (unresolved.isNotEmpty) {
    print('Unresolved ingredient products (${unresolved.length}):');
    final sorted = unresolved.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      print('  ${e.key} x${e.value}');
    }
  }

  if (dryRun) {
    print('Dry run — nothing written.');
    return;
  }
  const enc = JsonEncoder.withIndent('  ');
  await recipesFile.writeAsString('${enc.convert(recipesRaw)}\n');
  await productsFile.writeAsString('${enc.convert(productsRaw)}\n');
  print('Wrote ${SeedPaths.recipes} (${recipesRaw.length}) and '
      '${SeedPaths.products} (${productsRaw.length}).');
}
