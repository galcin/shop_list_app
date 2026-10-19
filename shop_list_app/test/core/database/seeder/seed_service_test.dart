import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/database/seeder/seed_data.dart';
import 'package:shop_list_app/core/database/seeder/seed_service.dart';
import 'package:shop_list_app/core/database/tables/app_meta_table.dart';

/// Runs the real bundled seed files (assets/data/*.json) against an
/// in-memory database. Tests run from the package root, so relative asset
/// paths resolve to the files that ship with the app.
void main() {
  late AppDatabase db;
  late SeedService seeder;

  Future<String> fileLoader(String path) => File(path).readAsString();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    seeder = SeedService(db, loader: fileLoader);
  });

  tearDown(() => db.close());

  test('applies the bundled seed once and links every ingredient', () async {
    final manifest = SeedManifest.parse(await fileLoader(SeedPaths.manifest));
    final expectedProducts =
        SeedProduct.parseList(await fileLoader(SeedPaths.products)).length;
    final expectedRecipes =
        SeedRecipe.parseList(await fileLoader(SeedPaths.recipes)).length;

    final first = await seeder.run();

    expect(first.applied, isTrue);
    expect(first.version, manifest.version);
    expect(first.unresolvedIngredients, 0,
        reason: 'every recipe ingredient must map to a catalogue product');
    expect((await db.select(db.products).get()).length, expectedProducts);
    expect((await db.select(db.recipes).get()).length, expectedRecipes);
    expect(await seeder.currentVersion(), manifest.version);

    final unlinked = await (db.select(db.recipeIngredients)
          ..where((t) => t.productId.isNull()))
        .get();
    expect(unlinked, isEmpty);

    final builtIns = await (db.select(db.recipes)
          ..where((t) => t.isBuiltIn.equals(false)))
        .get();
    expect(builtIns, isEmpty, reason: 'seeded recipes are built-in');

    final second = await seeder.run();
    expect(second.applied, isFalse);
    expect((await db.select(db.recipes).get()).length, expectedRecipes,
        reason: 'no duplicates on a second run');
  });

  test('adopts rows created by the old per-launch seeders', () async {
    // Shape of a database that had been seeded before seed versions existed:
    // categories/products/recipes by name, no built-in flags, no seed keys.
    final vegId = await db.into(db.productCategories).insert(
          ProductCategoriesCompanion.insert(name: 'Vegetables'),
        );
    final carrotsId = await db.into(db.products).insert(
          ProductsCompanion.insert(name: 'Carrots', productCategoryId: vegId),
        );
    final soupId = await db.into(db.recipes).insert(
          RecipesCompanion.insert(
            name: const Value('Chicken Soup'),
            favorite: const Value(true),
          ),
        );
    await db.into(db.recipeIngredients).insert(RecipeIngredientsCompanion.insert(
          recipeId: soupId,
          name: 'Carrots',
          quantity: const Value(2),
          unit: const Value('pcs'),
        ));

    await seeder.run();

    final carrots = await (db.select(db.products)
          ..where((t) => t.id.equals(carrotsId)))
        .getSingle();
    expect(carrots.isBuiltIn, isTrue);
    expect(carrots.aliases, contains('carrot'));
    final duplicates = await (db.select(db.products)
          ..where((t) => t.name.equals('Carrots')))
        .get();
    expect(duplicates, hasLength(1));

    final soup = await (db.select(db.recipes)..where((t) => t.id.equals(soupId)))
        .getSingle();
    expect(soup.isBuiltIn, isTrue);
    expect(soup.seedKey, 'chicken-soup');
    expect(soup.favorite, isTrue, reason: 'user state is kept');
    final soups = await (db.select(db.recipes)
          ..where((t) => t.name.equals('Chicken Soup')))
        .get();
    expect(soups, hasLength(1));

    final ingredients = await (db.select(db.recipeIngredients)
          ..where((t) => t.recipeId.equals(soupId)))
        .get();
    expect(ingredients.length, greaterThan(1));
    expect(ingredients.every((i) => i.productId != null), isTrue);
  });

  test('re-seeding leaves user-edited recipes and products alone', () async {
    await seeder.run();

    final soup = await (db.select(db.recipes)
          ..where((t) => t.seedKey.equals('chicken-soup')))
        .getSingle();
    await (db.update(db.recipes)..where((t) => t.id.equals(soup.id))).write(
      const RecipesCompanion(
        name: Value("Grandma's Chicken Soup"),
        isBuiltIn: Value(false),
      ),
    );
    await (db.delete(db.recipeIngredients)
          ..where((t) => t.recipeId.equals(soup.id)))
        .go();

    final carrots = await (db.select(db.products)
          ..where((t) => t.name.equals('Carrots')))
        .getSingle();
    await (db.update(db.products)..where((t) => t.id.equals(carrots.id))).write(
      const ProductsCompanion(photo: Value('🥕🥕'), isBuiltIn: Value(false)),
    );

    await (db.update(db.appMeta)
          ..where((t) => t.key.equals(AppMetaKeys.seedVersion)))
        .write(const AppMetaCompanion(value: Value('0')));
    // Not the very first run any more (version row exists), so no adoption.
    final result = await seeder.run(force: true);
    expect(result.applied, isTrue);

    final editedSoup = await (db.select(db.recipes)
          ..where((t) => t.id.equals(soup.id)))
        .getSingle();
    expect(editedSoup.name, "Grandma's Chicken Soup");
    expect(editedSoup.isBuiltIn, isFalse);
    expect(
        await (db.select(db.recipeIngredients)
              ..where((t) => t.recipeId.equals(soup.id)))
            .get(),
        isEmpty);
    final soups = await (db.select(db.recipes)
          ..where((t) => t.seedKey.equals('chicken-soup')))
        .get();
    expect(soups, hasLength(1), reason: 'edited built-in is not re-inserted');

    final editedCarrots = await (db.select(db.products)
          ..where((t) => t.id.equals(carrots.id)))
        .getSingle();
    expect(editedCarrots.photo, '🥕🥕');
  });
}
