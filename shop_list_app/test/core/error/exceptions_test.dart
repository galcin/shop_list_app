import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/exceptions.dart';

void main() {
  group('DatabaseException', () {
    test('stores message', () {
      const e = DatabaseException('db write failed');
      expect(e.message, 'db write failed');
    });

    test('toString includes class name and message', () {
      const e = DatabaseException('db write failed');
      expect(e.toString(), 'DatabaseException: db write failed');
    });
  });

  group('ValidationException', () {
    test('stores message', () {
      const e = ValidationException('name is required');
      expect(e.message, 'name is required');
    });

    test('toString includes class name and message', () {
      const e = ValidationException('name is required');
      expect(e.toString(), 'ValidationException: name is required');
    });
  });

  group('NetworkException', () {
    test('stores message', () {
      const e = NetworkException('request timed out');
      expect(e.message, 'request timed out');
    });

    test('toString includes class name and message', () {
      const e = NetworkException('request timed out');
      expect(e.toString(), 'NetworkException: request timed out');
    });
  });

  group('NotFoundException', () {
    test('stores message', () {
      const e = NotFoundException('recipe not found');
      expect(e.message, 'recipe not found');
    });

    test('toString includes class name and message', () {
      const e = NotFoundException('recipe not found');
      expect(e.toString(), 'NotFoundException: recipe not found');
    });
  });

  group('CacheException', () {
    test('stores message', () {
      const e = CacheException('preferences unavailable');
      expect(e.message, 'preferences unavailable');
    });

    test('toString includes class name and message', () {
      const e = CacheException('preferences unavailable');
      expect(e.toString(), 'CacheException: preferences unavailable');
    });
  });

  group('Exception is throwable/catchable', () {
    test('DatabaseException can be thrown and caught as Exception', () {
      expect(
        () => throw const DatabaseException('boom'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('ValidationException can be thrown and caught', () {
      expect(
        () => throw const ValidationException('invalid'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('NotFoundException can be thrown and caught', () {
      expect(
        () => throw const NotFoundException('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
