import 'package:drift/drift.dart';

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get instructions => text().nullable()();
  IntColumn get prepTime => integer().nullable()(); // minutes
  IntColumn get cookTime => integer().nullable()(); // minutes
  IntColumn get servings => integer().nullable()();
  BoolColumn get favorite => boolean().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get rating => real().nullable()();

  /// JSON-encoded List<String> of tag strings.
  TextColumn get tagsJson => text().nullable()();

  /// JSON-encoded List<{name, quantity, unit}> for ingredients.
  TextColumn get ingredientsJson => text().nullable()();
}
