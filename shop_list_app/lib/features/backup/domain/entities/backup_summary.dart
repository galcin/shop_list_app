/// Counts of what an import added to the database.
class ImportSummary {
  const ImportSummary({
    this.categories = 0,
    this.products = 0,
    this.recipes = 0,
    this.favorites = 0,
    this.shoppingLists = 0,
    this.shoppingItems = 0,
    this.pantryItems = 0,
    this.mealPlans = 0,
    this.mealSlots = 0,
    this.skippedRecipes = 0,
  });

  final int categories;
  final int products;
  final int recipes;
  final int favorites;
  final int shoppingLists;
  final int shoppingItems;
  final int pantryItems;
  final int mealPlans;
  final int mealSlots;

  /// Recipes skipped because an identical one already existed.
  final int skippedRecipes;

  int get total =>
      categories +
      products +
      recipes +
      shoppingLists +
      shoppingItems +
      pantryItems +
      mealPlans +
      mealSlots;

  /// Short human readable description, e.g. "12 recipes, 3 lists, 40 pantry items".
  String describe() {
    final parts = <String>[
      if (recipes > 0) '$recipes recipe${recipes == 1 ? '' : 's'}',
      if (favorites > 0) '$favorites favourite${favorites == 1 ? '' : 's'}',
      if (shoppingLists > 0)
        '$shoppingLists list${shoppingLists == 1 ? '' : 's'}',
      if (pantryItems > 0)
        '$pantryItems pantry item${pantryItems == 1 ? '' : 's'}',
      if (mealPlans > 0) '$mealPlans meal plan${mealPlans == 1 ? '' : 's'}',
      if (products > 0) '$products product${products == 1 ? '' : 's'}',
      if (categories > 0)
        '$categories categor${categories == 1 ? 'y' : 'ies'}',
    ];
    if (parts.isEmpty) return 'Nothing new to import';
    return 'Imported ${parts.join(', ')}';
  }
}

/// What an export produced.
class ExportResult {
  const ExportResult({
    required this.filePath,
    required this.fileName,
    required this.recipes,
    required this.shoppingLists,
    required this.pantryItems,
    required this.mealPlans,
  });

  final String filePath;
  final String fileName;
  final int recipes;
  final int shoppingLists;
  final int pantryItems;
  final int mealPlans;
}
