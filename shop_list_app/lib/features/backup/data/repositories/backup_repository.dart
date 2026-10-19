import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/database/seeder/seed_data.dart'
    show normalizeSeedName;
import 'package:shop_list_app/core/database/tables/app_meta_table.dart';
import 'package:shop_list_app/features/backup/domain/entities/backup_summary.dart';
import 'package:shop_list_app/features/backup/domain/repositories/i_backup_repository.dart';
import 'package:shop_list_app/features/meal_planning/domain/entities/meal_type.dart';

/// JSON backup of everything the user owns.
///
/// Format (version 1):
/// ```json
/// {
///   "format": "shop_list_backup", "version": 1, "exportedAt": "...",
///   "categories": [...], "products": [...],
///   "recipes": [...user recipes with ingredients...],
///   "favoriteSeedKeys": ["chicken-soup"],
///   "shoppingLists": [{ "name", "items": [...] }],
///   "pantryItems": [...],
///   "mealPlans": [{ "weekStartDate", "slots": [...] }]
/// }
/// ```
/// Cross-references use names and seed keys (never database ids) so a file
/// restores correctly on a device whose catalogue has different ids.
class BackupRepository implements IBackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  static const String format = 'shop_list_backup';
  static const int formatVersion = 1;

  // ── Export ─────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> exportData() async {
    final categories = await _db.select(_db.productCategories).get();
    final products = await _db.select(_db.products).get();
    final recipes = await _db.select(_db.recipes).get();
    final ingredients = await _db.select(_db.recipeIngredients).get();
    final lists = await (_db.select(_db.shoppingLists)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final items = await _db.select(_db.shoppingItems).get();
    final pantry = await (_db.select(_db.pantryItems)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final plans = await _db.select(_db.mealPlans).get();
    final slots = await _db.select(_db.mealSlots).get();
    final seedVersion = await (_db.select(_db.appMeta)
          ..where((t) => t.key.equals(AppMetaKeys.seedVersion)))
        .getSingleOrNull();

    final categoryName = {for (final c in categories) c.id: c.name};
    final productName = {for (final p in products) p.id: p.name};
    final recipeById = {for (final r in recipes) r.id: r};
    final ingredientsByRecipe = <int, List<RecipeIngredient>>{};
    for (final i in ingredients) {
      ingredientsByRecipe.putIfAbsent(i.recipeId, () => []).add(i);
    }
    final itemsByList = <int, List<ShoppingItem>>{};
    for (final i in items) {
      itemsByList.putIfAbsent(i.listId, () => []).add(i);
    }
    final slotsByPlan = <int, List<MealSlot>>{};
    for (final s in slots) {
      slotsByPlan.putIfAbsent(s.planId, () => []).add(s);
    }

    Map<String, dynamic> recipeRef(int? id) {
      final r = id != null ? recipeById[id] : null;
      if (r == null) return {};
      return r.isBuiltIn && r.seedKey != null
          ? {'seedKey': r.seedKey}
          : {'recipeName': r.name};
    }

    final userRecipes = recipes.where((r) => !r.isBuiltIn).toList();

    return {
      'format': format,
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'seedVersion': int.tryParse(seedVersion?.value ?? '') ?? 0,
      'categories': [
        for (final c in categories)
          {
            'name': c.name,
            'photo': c.photo,
            'colorHex': c.colorHex,
            'iconName': c.iconName,
            'imageName': c.imageName,
            'sortOrder': c.sortOrder,
            'isBuiltIn': c.isBuiltIn,
          }
      ],
      'products': [
        for (final p in products)
          {
            'name': p.name,
            'defaultUnit': p.defaultUnit,
            'photo': p.photo,
            'aliases': p.aliases,
            'category': categoryName[p.productCategoryId],
            'isBuiltIn': p.isBuiltIn,
          }
      ],
      'recipes': [
        for (final r in userRecipes)
          {
            'name': r.name,
            'description': r.description,
            'category': r.category,
            'instructions': r.instructions,
            'prepTime': r.prepTime,
            'cookTime': r.cookTime,
            'servings': r.servings,
            'favorite': r.favorite,
            'imageUrl': r.imageUrl,
            'rating': r.rating,
            'tags': r.tagsJson != null ? jsonDecode(r.tagsJson!) : <String>[],
            'seedKey': r.seedKey,
            'createdAt': r.createdAt.toIso8601String(),
            'ingredients': [
              for (final i in (ingredientsByRecipe[r.id] ?? const [])
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
                {
                  'name': i.name,
                  'product': productName[i.productId],
                  'quantity': i.quantity,
                  'unit': i.unit,
                  'note': i.note,
                }
            ],
          }
      ],
      'favoriteSeedKeys': [
        for (final r in recipes)
          if (r.isBuiltIn && r.favorite && r.seedKey != null) r.seedKey,
      ],
      'shoppingLists': [
        for (final l in lists)
          {
            'name': l.name,
            'createdAt': l.createdAt.toIso8601String(),
            'items': [
              for (final i in (itemsByList[l.id] ?? const []))
                {
                  'name': i.name,
                  'product': productName[i.productId],
                  'category': categoryName[i.categoryId],
                  'quantity': i.quantity,
                  'unit': i.unit,
                  'isChecked': i.isChecked,
                  'sortOrder': i.sortOrder,
                }
            ],
          }
      ],
      'pantryItems': [
        for (final p in pantry)
          {
            'name': p.name,
            'product': productName[p.productId],
            'category': categoryName[p.categoryId],
            'quantity': p.quantity,
            'unit': p.unit,
            'expiryDate': p.expiryDate?.toIso8601String(),
            'purchasedDate': p.purchasedDate.toIso8601String(),
            'location': p.location,
          }
      ],
      'mealPlans': [
        for (final plan in plans)
          {
            'weekStartDate': plan.weekStartDate.toIso8601String(),
            'slots': [
              for (final s in (slotsByPlan[plan.id] ?? const []))
                {
                  'date': s.date.toIso8601String(),
                  'mealType': s.mealType.index,
                  'customName': s.customName,
                  ...recipeRef(s.recipeId),
                }
            ],
          }
      ],
    };
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  @override
  Future<ImportSummary> importData(Map<String, dynamic> document) async {
    if (document['format'] != format) {
      throw const FormatException('Not a Shop List backup file.');
    }
    final version = (document['version'] as num?)?.toInt() ?? 0;
    if (version > formatVersion) {
      throw FormatException(
          'Backup version $version is newer than this app supports.');
    }

    return _db.transaction(() async {
      var summary = const ImportSummary();

      // ── Categories ─────────────────────────────────────────────────────
      final categoryIds = <String, int>{};
      for (final row in await _db.select(_db.productCategories).get()) {
        categoryIds[normalizeSeedName(row.name)] = row.id;
      }
      var newCategories = 0;
      for (final raw in _list(document['categories'])) {
        final name = (raw['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final key = normalizeSeedName(name);
        if (categoryIds.containsKey(key)) continue;
        final id = await _db.into(_db.productCategories).insert(
              ProductCategoriesCompanion.insert(
                name: name,
                photo: Value(raw['photo'] as String?),
                colorHex: Value(raw['colorHex'] as String?),
                iconName: Value(raw['iconName'] as String?),
                imageName: Value(raw['imageName'] as String?),
                sortOrder: Value((raw['sortOrder'] as num?)?.toInt() ?? 0),
              ),
            );
        categoryIds[key] = id;
        newCategories++;
      }
      int? categoryId(String? name) =>
          name == null ? null : categoryIds[normalizeSeedName(name)];
      final fallbackCategory =
          categoryIds.values.isEmpty ? null : categoryIds.values.first;

      // ── Products ───────────────────────────────────────────────────────
      final productIds = <String, int>{};
      for (final row in await _db.select(_db.products).get()) {
        productIds.putIfAbsent(normalizeSeedName(row.name), () => row.id);
        for (final alias in (row.aliases ?? '').split('|')) {
          final k = normalizeSeedName(alias);
          if (k.isNotEmpty) productIds.putIfAbsent(k, () => row.id);
        }
      }
      var newProducts = 0;
      for (final raw in _list(document['products'])) {
        final name = (raw['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final key = normalizeSeedName(name);
        if (productIds.containsKey(key)) continue;
        final catId = categoryId(raw['category'] as String?) ?? fallbackCategory;
        if (catId == null) continue;
        final id = await _db.into(_db.products).insert(ProductsCompanion.insert(
              name: name,
              defaultUnit: Value(raw['defaultUnit'] as String? ?? 'pcs'),
              photo: Value(raw['photo'] as String?),
              aliases: Value(raw['aliases'] as String?),
              productCategoryId: catId,
            ));
        productIds[key] = id;
        newProducts++;
      }
      int? productId(String? name) =>
          name == null ? null : productIds[normalizeSeedName(name)];

      // ── Recipes ────────────────────────────────────────────────────────
      final existingRecipes = await _db.select(_db.recipes).get();
      final userRecipeNames = {
        for (final r in existingRecipes)
          if (!r.isBuiltIn && r.name != null) normalizeSeedName(r.name!),
      };
      final recipeIdByName = <String, int>{
        for (final r in existingRecipes)
          if (r.name != null) normalizeSeedName(r.name!): r.id,
      };
      final recipeIdBySeedKey = <String, int>{
        for (final r in existingRecipes)
          if (r.seedKey != null) r.seedKey!: r.id,
      };
      var newRecipes = 0, skippedRecipes = 0;
      for (final raw in _list(document['recipes'])) {
        final name = (raw['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final key = normalizeSeedName(name);
        if (userRecipeNames.contains(key)) {
          skippedRecipes++;
          continue;
        }
        final tags = raw['tags'];
        final id = await _db.into(_db.recipes).insert(RecipesCompanion.insert(
              name: Value(name),
              description: Value(raw['description'] as String?),
              category: Value(raw['category'] as String?),
              instructions: Value(raw['instructions'] as String?),
              prepTime: Value((raw['prepTime'] as num?)?.toInt()),
              cookTime: Value((raw['cookTime'] as num?)?.toInt()),
              servings: Value((raw['servings'] as num?)?.toInt()),
              favorite: Value(raw['favorite'] as bool? ?? false),
              imageUrl: Value(raw['imageUrl'] as String?),
              rating: Value((raw['rating'] as num?)?.toDouble()),
              tagsJson: Value(tags is List && tags.isNotEmpty
                  ? jsonEncode(tags)
                  : null),
              isBuiltIn: const Value(false),
              seedKey: Value(raw['seedKey'] as String?),
            ));
        final lines = _list(raw['ingredients']);
        if (lines.isNotEmpty) {
          await _db.batch((b) => b.insertAll(_db.recipeIngredients, [
                for (var i = 0; i < lines.length; i++)
                  RecipeIngredientsCompanion.insert(
                    recipeId: id,
                    productId: Value(productId(lines[i]['product'] as String?)),
                    name: lines[i]['name'] as String? ?? '',
                    quantity: Value((lines[i]['quantity'] as num?)?.toDouble()),
                    unit: Value(lines[i]['unit'] as String? ?? ''),
                    note: Value(lines[i]['note'] as String?),
                    sortOrder: Value(i),
                  ),
              ]));
        }
        userRecipeNames.add(key);
        recipeIdByName[key] = id;
        newRecipes++;
      }

      var favorites = 0;
      for (final key in _list<dynamic>(document['favoriteSeedKeys'])) {
        final id = recipeIdBySeedKey[key.toString()];
        if (id == null) continue;
        final changed = await (_db.update(_db.recipes)
              ..where((t) => t.id.equals(id) & t.favorite.equals(false)))
            .write(const RecipesCompanion(favorite: Value(true)));
        favorites += changed;
      }

      // ── Shopping lists ─────────────────────────────────────────────────
      var newLists = 0, newItems = 0;
      for (final raw in _list(document['shoppingLists'])) {
        final name = (raw['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final listId = await _db.into(_db.shoppingLists).insert(
              ShoppingListsCompanion.insert(
                name: name,
                createdAt: Value(_date(raw['createdAt']) ?? DateTime.now()),
              ),
            );
        newLists++;
        final items = _list(raw['items']);
        if (items.isNotEmpty) {
          await _db.batch((b) => b.insertAll(_db.shoppingItems, [
                for (final i in items)
                  ShoppingItemsCompanion.insert(
                    listId: listId,
                    name: i['name'] as String? ?? '',
                    productId: Value(productId(i['product'] as String?)),
                    categoryId: Value(categoryId(i['category'] as String?)),
                    quantity: Value((i['quantity'] as num?)?.toDouble() ?? 1),
                    unit: Value(i['unit'] as String? ?? 'pcs'),
                    isChecked: Value(i['isChecked'] as bool? ?? false),
                    sortOrder: Value((i['sortOrder'] as num?)?.toInt() ?? 0),
                  ),
              ]));
          newItems += items.length;
        }
      }

      // ── Pantry ─────────────────────────────────────────────────────────
      var newPantry = 0;
      final pantryRows = _list(document['pantryItems']);
      if (pantryRows.isNotEmpty && fallbackCategory != null) {
        await _db.batch((b) => b.insertAll(_db.pantryItems, [
              for (final p in pantryRows)
                PantryItemsCompanion.insert(
                  name: p['name'] as String? ?? '',
                  productId: Value(productId(p['product'] as String?)),
                  categoryId:
                      categoryId(p['category'] as String?) ?? fallbackCategory,
                  quantity: (p['quantity'] as num?)?.toDouble() ?? 1,
                  unit: p['unit'] as String? ?? 'pcs',
                  expiryDate: Value(_date(p['expiryDate'])),
                  purchasedDate:
                      Value(_date(p['purchasedDate']) ?? DateTime.now()),
                  location: Value(p['location'] as String?),
                ),
            ]));
        newPantry = pantryRows.length;
      }

      // ── Meal plans ─────────────────────────────────────────────────────
      final existingPlans = {
        for (final p in await _db.select(_db.mealPlans).get())
          p.weekStartDate.toIso8601String(): p.id,
      };
      var newPlans = 0, newSlots = 0;
      for (final raw in _list(document['mealPlans'])) {
        final weekStart = _date(raw['weekStartDate']);
        if (weekStart == null) continue;
        var planId = existingPlans[weekStart.toIso8601String()];
        if (planId == null) {
          planId = await _db.into(_db.mealPlans).insert(
                MealPlansCompanion.insert(weekStartDate: weekStart),
              );
          existingPlans[weekStart.toIso8601String()] = planId;
          newPlans++;
        }
        final existingSlots = await (_db.select(_db.mealSlots)
              ..where((t) => t.planId.equals(planId!)))
            .get();
        for (final s in _list(raw['slots'])) {
          final date = _date(s['date']);
          final mealType = (s['mealType'] as num?)?.toInt();
          if (date == null || mealType == null) continue;
          final recipeId = s['seedKey'] != null
              ? recipeIdBySeedKey[s['seedKey'] as String]
              : s['recipeName'] != null
                  ? recipeIdByName[normalizeSeedName(s['recipeName'] as String)]
                  : null;
          final customName = s['customName'] as String?;
          if (recipeId == null && customName == null) continue;

          final clash = existingSlots.where((e) =>
              e.date == date &&
              e.mealType.index == mealType &&
              (e.recipeId != null || e.customName != null));
          if (clash.isNotEmpty) continue; // never overwrite a planned meal

          final empty = existingSlots.where(
              (e) => e.date == date && e.mealType.index == mealType);
          if (empty.isNotEmpty) {
            await (_db.update(_db.mealSlots)
                  ..where((t) => t.id.equals(empty.first.id)))
                .write(MealSlotsCompanion(
              recipeId: Value(recipeId),
              customName: Value(customName),
            ));
          } else {
            await _db.into(_db.mealSlots).insert(MealSlotsCompanion.insert(
                  planId: planId,
                  date: date,
                  mealType: _mealType(mealType),
                  recipeId: Value(recipeId),
                  customName: Value(customName),
                ));
          }
          newSlots++;
        }
      }

      summary = ImportSummary(
        categories: newCategories,
        products: newProducts,
        recipes: newRecipes,
        favorites: favorites,
        shoppingLists: newLists,
        shoppingItems: newItems,
        pantryItems: newPantry,
        mealPlans: newPlans,
        mealSlots: newSlots,
        skippedRecipes: skippedRecipes,
      );
      return summary;
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<T> _list<T>(dynamic value) {
    if (value is! List) return const [];
    if (T == dynamic) return value.cast<T>();
    return value.map((e) => Map<String, dynamic>.from(e as Map) as T).toList();
  }

  DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  MealType _mealType(int index) =>
      MealType.values[index.clamp(0, MealType.values.length - 1)];
}
