import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/database/app_database.dart'
    hide ProductCategory;
import 'package:shop_list_app/features/shopping/data/datasources/product_category_data_source.dart';
import 'package:shop_list_app/features/shopping/data/repositories/product_category_repository.dart';
import 'package:shop_list_app/features/shopping/domain/entities/product_category.dart';

void main() {
  late AppDatabase db;
  late ProductCategoryDataSource dataSource;
  late ProductCategoryRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProductCategoryDataSource(db);
    repository = ProductCategoryRepository(dataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProductCategoryRepository', () {
    test('save() inserts a new category and returns the entity with a db id',
        () async {
      const category = ProductCategory(
        id: 0,
        name: 'Dairy',
        colorHex: '#4CAF50',
        iconName: '🥛',
      );

      final result = await repository.save(category);

      expect(result.isRight(), isTrue);
      result.fold((f) => fail('Expected Right but got $f'), (saved) {
        expect(saved.name, 'Dairy');
        expect(saved.colorHex, '#4CAF50');
        expect(saved.iconName, '🥛');
        expect(saved.id, greaterThan(0));
        expect(saved.createdAt, isNotNull);
        expect(saved.updatedAt, isNotNull);
      });
    });

    test('watchAll() emits the saved category', () async {
      const category = ProductCategory(id: 0, name: 'Bakery');
      await repository.save(category);

      final stream = repository.watchAll();
      final emission = await stream.first;

      emission.fold(
        (f) => fail('Expected Right but got $f'),
        (list) {
          expect(list.length, 1);
          expect(list.first.name, 'Bakery');
        },
      );
    });

    test('save() and then watchAll() are consistent', () async {
      await repository.save(const ProductCategory(id: 0, name: 'Fruits'));
      await repository.save(const ProductCategory(id: 0, name: 'Veggies'));

      final emission = await repository.watchAll().first;
      emission.fold(
        (f) => fail('Expected Right'),
        (list) => expect(list.length, 2),
      );
    });

    test('update() changes the category name', () async {
      final saved = (await repository.save(
        const ProductCategory(id: 0, name: 'Old Name'),
      ))
          .getOrElse(() => throw Exception('save failed'));

      final updated = await repository.update(
        saved.copyWith(name: 'New Name'),
      );

      updated.fold(
        (f) => fail('Expected Right'),
        (c) => expect(c.name, 'New Name'),
      );
    });

    test('delete() returns Right(true) when no products assigned', () async {
      final saved = (await repository.save(
        const ProductCategory(id: 0, name: 'Empty'),
      ))
          .getOrElse(() => throw Exception('save failed'));

      final result = await repository.delete(saved.id);

      expect(result.isRight(), isTrue);
    });
  });
}
