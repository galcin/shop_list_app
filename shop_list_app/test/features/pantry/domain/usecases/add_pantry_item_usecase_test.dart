import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';
import 'package:shop_list_app/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:shop_list_app/features/pantry/domain/usecases/add_pantry_item_usecase.dart';

class MockIPantryRepository implements IPantryRepository {
  int? nextSaveId = 42;

  @override
  Future<int> save(PantryItem item) {
    if (nextSaveId != null) {
      return Future.value(nextSaveId!);
    }
    return Future.error(UnimplementedError());
  }

  @override
  Future<bool> update(PantryItem item) async => throw UnimplementedError();

  @override
  Future<bool> delete(int id) async => throw UnimplementedError();

  @override
  Future<List<PantryItem>> getAll() async => throw UnimplementedError();

  @override
  Future<PantryItem?> getById(int id) async => throw UnimplementedError();

  @override
  Stream<List<PantryItem>> watchAll() => throw UnimplementedError();

  @override
  Stream<List<PantryItem>> watchExpiringSoon({required int days}) =>
      throw UnimplementedError();
}

void main() {
  group('AddPantryItemUseCase', () {
    late AddPantryItemUseCase useCase;
    late MockIPantryRepository mockRepository;

    setUp(() {
      mockRepository = MockIPantryRepository();
      useCase = AddPantryItemUseCase(mockRepository);
    });

    test('rejects quantity <= 0', () async {
      final result = await useCase.call(
        name: 'Milk',
        quantity: 0,
        unit: 'L',
        categoryId: 1,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.toString(), contains('greater than 0')),
        (_) => fail('Should have failed'),
      );
    });

    test('rejects empty name', () async {
      final result = await useCase.call(
        name: '',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.toString(), contains('required')),
        (_) => fail('Should have failed'),
      );
    });

    test('rejects empty unit', () async {
      final result = await useCase.call(
        name: 'Milk',
        quantity: 1.0,
        unit: '',
        categoryId: 1,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.toString(), contains('required')),
        (_) => fail('Should have failed'),
      );
    });

    test('returns Right with id on successful add', () async {
      mockRepository.nextSaveId = 42;

      final result = await useCase.call(
        name: 'Milk',
        quantity: 1.5,
        unit: 'L',
        categoryId: 1,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have succeeded'),
        (id) => expect(id, 42),
      );
    });
  });
}
