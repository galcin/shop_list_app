import 'package:drift/drift.dart';
import 'product_category_table.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get units => text()();
  TextColumn get photo => text()();
  DateTimeColumn get expirationDate => dateTime()();
  IntColumn get productCategoryId =>
      integer().references(ProductCategories, #id)();
}
