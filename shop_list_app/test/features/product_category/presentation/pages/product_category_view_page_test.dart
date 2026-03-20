import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/product_category/domain/entities/product_category.dart';
import 'package:shop_list_app/features/product_category/domain/repositories/i_product_category_repository.dart';
import 'package:shop_list_app/features/product_category/presentation/pages/product_category_view_page.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';

const _kThree = [
  ProductCategory(id: 1, name: 'Dairy', iconName: '??', colorHex: '#4CAF50'),
  ProductCategory(id: 2, name: 'Produce', iconName: '??', colorHex: '#2196F3'),
  ProductCategory(id: 3, name: 'Meat', iconName: '??', colorHex: '#FF9800'),
];

class _ThreeCategoriesNotifier extends ProductCategoryListNotifier {
  @override
  Future<List<ProductCategory>> build() async => _kThree;
}

class _EmptyCategoriesNotifier extends ProductCategoryListNotifier {
  @override
  Future<List<ProductCategory>> build() async => const [];
}

Widget _buildScoped(ProductCategoryListNotifier Function() factory) {
  return ProviderScope(
    overrides: [
      productCategoryRepositoryProvider
          .overrideWith((ref) => _NullRepository()),
      productCategoryListProvider.overrideWith(factory),
    ],
    child: const MaterialApp(home: ProductCategoryViewPage()),
  );
}

void main() {
  testWidgets('renders 3 mocked categories in the grid', (tester) async {
    await tester.pumpWidget(_buildScoped(_ThreeCategoriesNotifier.new));
    await tester.pump();
    expect(find.text('Dairy'), findsOneWidget);
    expect(find.text('Produce'), findsOneWidget);
    expect(find.text('Meat'), findsOneWidget);
  });

  testWidgets('FAB is visible on the page', (tester) async {
    await tester.pumpWidget(_buildScoped(_ThreeCategoriesNotifier.new));
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });

  testWidgets('shows empty-state widget when no categories', (tester) async {
    await tester.pumpWidget(_buildScoped(_EmptyCategoriesNotifier.new));
    await tester.pump();
    expect(find.text('No categories yet'), findsOneWidget);
  });

  testWidgets('shows page title "Categories"', (tester) async {
    await tester.pumpWidget(_buildScoped(_ThreeCategoriesNotifier.new));
    await tester.pump();
    expect(find.text('Categories'), findsOneWidget);
  });
}

class _NullRepository implements IProductCategoryRepository {
  @override
  Stream<Either<Failure, List<ProductCategory>>> watchAll() =>
      const Stream.empty();

  @override
  Future<Either<Failure, ProductCategory>> save(ProductCategory c) async =>
      Right(c);

  @override
  Future<Either<Failure, ProductCategory>> update(ProductCategory c) async =>
      Right(c);

  @override
  Future<Either<Failure, bool>> delete(int id) async => const Right(true);

  @override
  Future<Either<Failure, bool>> reorder(List<int> ids) async =>
      const Right(true);

  @override
  Future<int> countProductsForCategory(int id) async => 0;

  @override
  Future<List<ProductCategory>> getAllCategories() async => const [];

  @override
  Future<ProductCategory?> getCategoryById(int id) async => null;

  @override
  Future<int> addCategory(ProductCategory c) async => 0;

  @override
  Future<bool> updateCategory(ProductCategory c) async => true;

  @override
  Future<bool> deleteCategory(int id) async => true;
}
