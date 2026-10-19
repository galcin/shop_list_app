import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/database/tables/app_meta_table.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';

import 'seed_data.dart';

/// Loads a text asset by path. Injected so tests can read from disk.
typedef SeedAssetLoader = Future<String> Function(String path);

Future<String> _bundleLoader(String path) => rootBundle.loadString(path);

/// Outcome of a [SeedService.run] call.
class SeedResult {
  const SeedResult({
    required this.applied,
    required this.version,
    this.categories = 0,
    this.products = 0,
    this.recipes = 0,
    this.unresolvedIngredients = 0,
  });

  /// `false` when the database was already at the bundled seed version.
  final bool applied;
  final int version;
  final int categories;
  final int products;
  final int recipes;

  /// Ingredient lines whose product name could not be matched to the
  /// catalogue. They are still inserted, just without a product link.
  final int unresolvedIngredients;

  @override
  String toString() => applied
      ? 'SeedResult(v$version: $categories categories, $products products, '
          '$recipes recipes, $unresolvedIngredients unresolved ingredients)'
      : 'SeedResult(v$version already applied)';
}

/// Applies the bundled seed data (categories, products, recipes) to the
/// database exactly once per seed version.
///
/// Rules:
/// * Rows are matched by stable keys — category/product name, recipe
///   `seedKey` — never by database id.
/// * Only rows flagged `isBuiltIn` are updated. Anything the user created or
///   edited (flag cleared) is left untouched.
/// * On the very first run (no seed version stored yet) rows that match a seed
///   entry by name are adopted as built-in. This migrates databases created
///   by the older per-launch seeders.
class SeedService {
  SeedService(this._db, {SeedAssetLoader? loader})
      : _load = loader ?? _bundleLoader;

  final AppDatabase _db;
  final SeedAssetLoader _load;

  Future<int> currentVersion() async {
    final row = await (_db.select(_db.appMeta)
          ..where((t) => t.key.equals(AppMetaKeys.seedVersion)))
        .getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  /// Runs the seed when the bundled version is newer than the stored one
  /// (or always when [force] is set).
  Future<SeedResult> run({bool force = false}) async {
    final manifest = SeedManifest.parse(await _load(SeedPaths.manifest));
    final current = await currentVersion();
    if (!force && current >= manifest.version) {
      return SeedResult(applied: false, version: manifest.version);
    }

    AppLogger.instance.info(
        '[Seed] Applying seed v${manifest.version} (database at v$current)');

    final categories =
        SeedCategory.parseList(await _load(SeedPaths.categories));
    final products = SeedProduct.parseList(await _load(SeedPaths.products));
    final recipes = SeedRecipe.parseList(await _load(SeedPaths.recipes));
    final adoptByName = current == 0;

    late SeedResult result;
    await _db.transaction(() async {
      final categoryIds = await _seedCategories(categories, adoptByName);
      final productIndex = await _seedProducts(
          products, categoryIds, adoptByName);
      final unresolved = await _seedRecipes(recipes, productIndex, adoptByName);

      await _db.into(_db.appMeta).insertOnConflictUpdate(
            AppMetaCompanion.insert(
              key: AppMetaKeys.seedVersion,
              value: manifest.version.toString(),
            ),
          );

      result = SeedResult(
        applied: true,
        version: manifest.version,
        categories: categories.length,
        products: products.length,
        recipes: recipes.length,
        unresolvedIngredients: unresolved,
      );
    });

    AppLogger.instance.info('[Seed] $result');
    return result;
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<Map<String, int>> _seedCategories(
      List<SeedCategory> seeds, bool adoptByName) async {
    final existing = await _db.select(_db.productCategories).get();
    final byName = {
      for (final row in existing) normalizeSeedName(row.name): row,
    };
    final ids = <String, int>{};
    final now = DateTime.now();

    for (final seed in seeds) {
      final key = normalizeSeedName(seed.name);
      final row = byName[key];
      if (row == null) {
        final id = await _db.into(_db.productCategories).insert(
              ProductCategoriesCompanion.insert(
                name: seed.name,
                photo: Value(seed.emoji),
                iconName: Value(seed.emoji),
                colorHex: Value(seed.colorHex),
                imageName: Value(seed.imageName),
                sortOrder: Value(seed.sortOrder),
                isBuiltIn: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
        ids[key] = id;
      } else {
        ids[key] = row.id;
        if (row.isBuiltIn || adoptByName) {
          await (_db.update(_db.productCategories)
                ..where((t) => t.id.equals(row.id)))
              .write(ProductCategoriesCompanion(
            photo: Value(seed.emoji ?? row.photo),
            iconName: Value(seed.emoji ?? row.iconName),
            colorHex: Value(seed.colorHex ?? row.colorHex),
            imageName: Value(seed.imageName ?? row.imageName),
            sortOrder: Value(seed.sortOrder),
            isBuiltIn: const Value(true),
            updatedAt: Value(now),
          ));
        }
      }
    }
    // User categories keep their ids too, so products may reference them.
    for (final row in existing) {
      ids.putIfAbsent(normalizeSeedName(row.name), () => row.id);
    }
    return ids;
  }

  // ── Products ───────────────────────────────────────────────────────────────

  Future<_ProductIndex> _seedProducts(
    List<SeedProduct> seeds,
    Map<String, int> categoryIds,
    bool adoptByName,
  ) async {
    final existing = await _db.select(_db.products).get();
    final byName = {
      for (final row in existing) normalizeSeedName(row.name): row,
    };
    final now = DateTime.now();
    final index = _ProductIndex();

    // Every existing product is addressable by name (and stored aliases).
    for (final row in existing) {
      index.add(row.id, normalizeSeedName(row.name));
      for (final alias in (row.aliases ?? '').split('|')) {
        index.add(row.id, normalizeSeedName(alias));
      }
    }

    final inserts = <ProductsCompanion>[];
    final pendingKeys = <List<String>>[];

    for (final seed in seeds) {
      final key = normalizeSeedName(seed.name);
      final categoryId = categoryIds[normalizeSeedName(seed.category)];
      if (categoryId == null) {
        AppLogger.instance.warning(
            '[Seed] Product "${seed.name}" references unknown category '
            '"${seed.category}" — skipped');
        continue;
      }
      final aliases = seed.aliases.isEmpty ? null : seed.aliases.join('|');
      final row = byName[key];
      if (row == null) {
        inserts.add(ProductsCompanion.insert(
          name: seed.name,
          defaultUnit: Value(seed.unit),
          photo: Value(seed.photo),
          aliases: Value(aliases),
          productCategoryId: categoryId,
          isBuiltIn: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
        pendingKeys.add(seed.lookupKeys.toList());
      } else if (row.isBuiltIn || adoptByName) {
        await (_db.update(_db.products)..where((t) => t.id.equals(row.id)))
            .write(ProductsCompanion(
          name: Value(seed.name),
          defaultUnit: Value(seed.unit),
          // Keep a user-chosen photo if the seed has none.
          photo: Value(seed.photo ?? row.photo),
          aliases: Value(aliases ?? row.aliases),
          productCategoryId: Value(categoryId),
          isBuiltIn: const Value(true),
          updatedAt: Value(now),
        ));
        for (final k in seed.lookupKeys) {
          index.add(row.id, k);
        }
      } else {
        for (final k in seed.lookupKeys) {
          index.add(row.id, k);
        }
      }
    }

    // Batch insert, then read ids back by name (SQLite returns no ids for
    // batch inserts).
    if (inserts.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.products, inserts));
      final names = inserts.map((c) => c.name.value).toList();
      final rows = await (_db.select(_db.products)
            ..where((t) => t.name.isIn(names)))
          .get();
      final idByName = {
        for (final r in rows) normalizeSeedName(r.name): r.id,
      };
      for (var i = 0; i < inserts.length; i++) {
        final id = idByName[normalizeSeedName(inserts[i].name.value)];
        if (id == null) continue;
        for (final k in pendingKeys[i]) {
          index.add(id, k);
        }
      }
    }
    return index;
  }

  // ── Recipes ────────────────────────────────────────────────────────────────

  /// Returns the number of ingredient lines that could not be linked.
  Future<int> _seedRecipes(
    List<SeedRecipe> seeds,
    _ProductIndex products,
    bool adoptByName,
  ) async {
    final existing = await _db.select(_db.recipes).get();
    final bySeedKey = <String, Recipe>{
      for (final row in existing)
        if (row.seedKey != null) row.seedKey!: row,
    };
    // Legacy rows (seeded by name before seed versions existed).
    final legacyByName = <String, Recipe>{
      if (adoptByName)
        for (final row in existing)
          if (row.seedKey == null && !row.isBuiltIn && row.name != null)
            normalizeSeedName(row.name!): row,
    };
    final now = DateTime.now();
    var unresolved = 0;

    final newRecipes = <RecipesCompanion>[];
    final newRecipeIngredients = <SeedRecipe>[];

    for (final seed in seeds) {
      final existingRow =
          bySeedKey[seed.key] ?? legacyByName[normalizeSeedName(seed.name)];

      if (existingRow == null) {
        newRecipes.add(_recipeCompanion(seed, now, createdAt: now));
        newRecipeIngredients.add(seed);
        continue;
      }

      final editable = existingRow.isBuiltIn || adoptByName;
      if (!editable) continue;

      await (_db.update(_db.recipes)
            ..where((t) => t.id.equals(existingRow.id)))
          .write(_recipeCompanion(seed, now));
      await (_db.delete(_db.recipeIngredients)
            ..where((t) => t.recipeId.equals(existingRow.id)))
          .go();
      unresolved += await _insertIngredients(existingRow.id, seed, products);
    }

    if (newRecipes.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.recipes, newRecipes));
      final keys = newRecipeIngredients.map((r) => r.key).toList();
      final rows = await (_db.select(_db.recipes)
            ..where((t) => t.seedKey.isIn(keys)))
          .get();
      final idByKey = {for (final r in rows) r.seedKey!: r.id};
      final companions = <RecipeIngredientsCompanion>[];
      for (final seed in newRecipeIngredients) {
        final id = idByKey[seed.key];
        if (id == null) continue;
        final built = _ingredientCompanions(id, seed, products);
        unresolved += built.unresolved;
        companions.addAll(built.companions);
      }
      if (companions.isNotEmpty) {
        await _db.batch((b) => b.insertAll(_db.recipeIngredients, companions));
      }
    }
    return unresolved;
  }

  RecipesCompanion _recipeCompanion(SeedRecipe seed, DateTime now,
      {DateTime? createdAt}) {
    return RecipesCompanion(
      name: Value(seed.name),
      description: Value(seed.description),
      category: Value(seed.category),
      instructions: Value(seed.instructions.join('\n')),
      prepTime: Value(seed.prepTime),
      cookTime: Value(seed.cookTime),
      servings: Value(seed.servings),
      imageUrl: Value(seed.imageUrl),
      tagsJson: Value(seed.tags.isEmpty ? null : jsonEncode(seed.tags)),
      isBuiltIn: const Value(true),
      seedKey: Value(seed.key),
      updatedAt: Value(now),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
    );
  }

  Future<int> _insertIngredients(
      int recipeId, SeedRecipe seed, _ProductIndex products) async {
    final built = _ingredientCompanions(recipeId, seed, products);
    if (built.companions.isNotEmpty) {
      await _db.batch(
          (b) => b.insertAll(_db.recipeIngredients, built.companions));
    }
    return built.unresolved;
  }

  _BuiltIngredients _ingredientCompanions(
      int recipeId, SeedRecipe seed, _ProductIndex products) {
    var unresolved = 0;
    final companions = <RecipeIngredientsCompanion>[];
    for (var i = 0; i < seed.ingredients.length; i++) {
      final ing = seed.ingredients[i];
      final productId = products.resolve(ing.product);
      if (productId == null) {
        unresolved++;
        AppLogger.instance.warning(
            '[Seed] "${seed.name}": no catalogue product for "${ing.product}"');
      }
      companions.add(RecipeIngredientsCompanion.insert(
        recipeId: recipeId,
        productId: Value(productId),
        name: ing.displayName,
        quantity: Value(ing.quantity),
        unit: Value(ing.unit),
        note: Value(ing.note),
        sortOrder: Value(i),
      ));
    }
    return _BuiltIngredients(companions, unresolved);
  }
}

class _BuiltIngredients {
  const _BuiltIngredients(this.companions, this.unresolved);
  final List<RecipeIngredientsCompanion> companions;
  final int unresolved;
}

/// Name/alias -> product id lookup with the same plural tolerance as
/// [SeedProductIndex].
class _ProductIndex {
  final Map<String, int> _byKey = {};

  void add(int id, String key) {
    if (key.isEmpty) return;
    _byKey.putIfAbsent(key, () => id);
  }

  int? resolve(String name) {
    final key = normalizeSeedName(name);
    if (key.isEmpty) return null;
    final direct = _byKey[key];
    if (direct != null) return direct;
    if (key.endsWith('s')) {
      final singular = _byKey[key.substring(0, key.length - 1)];
      if (singular != null) return singular;
    }
    return _byKey['${key}s'];
  }
}
