// ignore_for_file: avoid_print
//
// Seed data validator.
//
// Checks assets/data/product_categories.json, products.json and recipes.json
// for the problems that would otherwise only show up at runtime:
//   * products that reference an unknown category
//   * duplicate product names / aliases pointing at different products
//   * recipe ingredients whose `product` matches no catalogue name or alias
//   * unknown units, non-numeric quantities, duplicate recipe keys/names
//   * referenced image files that do not exist on disk
//
// With --write-manifest it also refreshes assets/data/seed_manifest.json
// (counts and timestamp; the version is bumped only with --bump-version).
//
// Run from the project root:
//
//   dart run tool/seed/validate_seed.dart
//   dart run tool/seed/validate_seed.dart --write-manifest [--bump-version]
import 'dart:convert';
import 'dart:io';

import 'package:shop_list_app/core/constants/units.dart';
import 'package:shop_list_app/core/database/seeder/seed_data.dart';

Future<void> main(List<String> args) async {
  final writeManifest = args.contains('--write-manifest');
  final bumpVersion = args.contains('--bump-version');
  final verbose = args.contains('--verbose');

  final errors = <String>[];
  final warnings = <String>[];

  final categories =
      SeedCategory.parseList(await File(SeedPaths.categories).readAsString());
  final products =
      SeedProduct.parseList(await File(SeedPaths.products).readAsString());
  final recipes =
      SeedRecipe.parseList(await File(SeedPaths.recipes).readAsString());

  // ── Categories ────────────────────────────────────────────────────────────
  final categoryKeys = <String>{};
  for (final c in categories) {
    final key = normalizeSeedName(c.name);
    if (!categoryKeys.add(key)) errors.add('Duplicate category "${c.name}"');
    if (c.imageName != null &&
        !File('assets/images/${c.imageName}').existsSync()) {
      errors.add('Category "${c.name}": image ${c.imageName} not found');
    }
  }

  // ── Products ──────────────────────────────────────────────────────────────
  final keyOwner = <String, String>{};
  for (final p in products) {
    if (!categoryKeys.contains(normalizeSeedName(p.category))) {
      errors.add('Product "${p.name}": unknown category "${p.category}"');
    }
    if (!Units.isKnown(p.unit)) {
      errors.add('Product "${p.name}": unknown unit "${p.unit}"');
    }
    if (p.image != null && !File(p.image!).existsSync()) {
      errors.add('Product "${p.name}": image ${p.image} not found');
    }
    for (final key in p.lookupKeys) {
      final owner = keyOwner[key];
      if (owner != null && owner != p.name) {
        errors.add('Name/alias "$key" used by both "$owner" and "${p.name}"');
      }
      keyOwner[key] = p.name;
    }
  }

  // ── Recipes ───────────────────────────────────────────────────────────────
  final index = SeedProductIndex(products);
  final recipeKeys = <String>{};
  final recipeNames = <String>{};
  final unresolved = <String, List<String>>{};
  final categoryCounts = <String, int>{};
  var ingredientLines = 0;

  for (final r in recipes) {
    if (!recipeKeys.add(r.key)) errors.add('Duplicate recipe key "${r.key}"');
    if (!recipeNames.add(normalizeSeedName(r.name))) {
      errors.add('Duplicate recipe name "${r.name}"');
    }
    categoryCounts[r.category] = (categoryCounts[r.category] ?? 0) + 1;
    if (r.ingredients.isEmpty) errors.add('Recipe "${r.name}" has no ingredients');
    if (r.instructions.isEmpty) {
      warnings.add('Recipe "${r.name}" has no instructions');
    }
    if (r.servings == null) warnings.add('Recipe "${r.name}" has no servings');
    if (r.prepTime == null && r.cookTime == null) {
      warnings.add('Recipe "${r.name}" has no prep/cook time');
    }
    if (r.imageUrl != null && !File(r.imageUrl!).existsSync()) {
      errors.add('Recipe "${r.name}": image ${r.imageUrl} not found');
    }
    for (final ing in r.ingredients) {
      ingredientLines++;
      if (index.resolve(ing.product) == null) {
        unresolved.putIfAbsent(ing.product, () => []).add(r.name);
      }
      if (!Units.isKnown(ing.unit)) {
        errors.add('Recipe "${r.name}": unknown unit "${ing.unit}" '
            'for ${ing.product}');
      }
      if (ing.quantity == null && (ing.note == null || ing.note!.isEmpty)) {
        warnings.add(
            'Recipe "${r.name}": "${ing.product}" has no quantity and no note');
      }
      if (ing.quantity != null && ing.quantity! <= 0) {
        errors.add(
            'Recipe "${r.name}": "${ing.product}" has quantity ${ing.quantity}');
      }
    }
  }

  // ── Report ────────────────────────────────────────────────────────────────
  print('Categories: ${categories.length}');
  print('Products:   ${products.length} (${keyOwner.length} lookup keys)');
  print('Recipes:    ${recipes.length} ($ingredientLines ingredient lines)');
  final sortedCats = categoryCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final e in sortedCats) {
    print('  ${e.key.padRight(18)} ${e.value}');
  }

  if (unresolved.isNotEmpty) {
    print('\nUnresolved ingredient products (${unresolved.length}):');
    final sorted = unresolved.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    for (final e in sorted) {
      final where = verbose ? '  <- ${e.value.join(', ')}' : '';
      print('  ${e.key.padRight(28)} x${e.value.length}$where');
    }
  }
  if (warnings.isNotEmpty) {
    print('\nWarnings (${warnings.length}):');
    for (final w in warnings.take(verbose ? warnings.length : 25)) {
      print('  $w');
    }
    if (!verbose && warnings.length > 25) {
      print('  … ${warnings.length - 25} more (use --verbose)');
    }
  }
  if (errors.isNotEmpty) {
    print('\nErrors (${errors.length}):');
    for (final e in errors) {
      print('  $e');
    }
  }

  final ok = errors.isEmpty && unresolved.isEmpty;
  print(ok ? '\nSeed data OK.' : '\nSeed data has problems.');

  if (writeManifest) {
    final manifestFile = File(SeedPaths.manifest);
    final current = manifestFile.existsSync()
        ? SeedManifest.parse(await manifestFile.readAsString())
        : const SeedManifest(version: 0);
    final manifest = {
      'version': bumpVersion ? current.version + 1 : current.version,
      'generatedAt': DateTime.now().toIso8601String().substring(0, 10),
      'recipeCount': recipes.length,
      'productCount': products.length,
    };
    await manifestFile.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(manifest)}\n');
    print('Wrote ${SeedPaths.manifest} (version ${manifest['version']})');
  }

  exitCode = ok ? 0 : 1;
}
