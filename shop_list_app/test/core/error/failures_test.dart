import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/error/failures.dart';

void main() {
  group('DatabaseFailure', () {
    test('creates instance with message', () {
      const failure = DatabaseFailure('db error');
      expect(failure.message, 'db error');
      expect(failure.code, isNull);
    });

    test('equality holds for same message', () {
      const a = DatabaseFailure('db error');
      const b = DatabaseFailure('db error');
      expect(a, equals(b));
    });

    test('inequality for different messages', () {
      const a = DatabaseFailure('err1');
      const b = DatabaseFailure('err2');
      expect(a, isNot(equals(b)));
    });
  });

  group('ValidationFailure', () {
    test('creates instance with message', () {
      const failure = ValidationFailure('required field');
      expect(failure.message, 'required field');
    });

    test('equality works', () {
      expect(
        const ValidationFailure('x'),
        equals(const ValidationFailure('x')),
      );
    });
  });

  group('NetworkFailure', () {
    test('creates instance with message', () {
      const failure = NetworkFailure('no internet');
      expect(failure.message, 'no internet');
    });

    test('equality works', () {
      expect(
        const NetworkFailure('offline'),
        equals(const NetworkFailure('offline')),
      );
    });
  });

  group('NotFoundFailure', () {
    test('creates instance with message', () {
      const failure = NotFoundFailure('recipe not found');
      expect(failure.message, 'recipe not found');
    });

    test('equality works', () {
      expect(
        const NotFoundFailure('404'),
        equals(const NotFoundFailure('404')),
      );
    });
  });

  group('CacheFailure', () {
    test('creates instance with message', () {
      const failure = CacheFailure('cache miss');
      expect(failure.message, 'cache miss');
    });

    test('equality works', () {
      expect(
        const CacheFailure('cache miss'),
        equals(const CacheFailure('cache miss')),
      );
    });
  });

  group('ServerFailure', () {
    test('creates instance with message only', () {
      const failure = ServerFailure('internal server error');
      expect(failure.message, 'internal server error');
      expect(failure.code, isNull);
    });

    test('creates instance with message and status code', () {
      const failure = ServerFailure('unauthorized', code: 401);
      expect(failure.message, 'unauthorized');
      expect(failure.code, 401);
    });

    test('equality holds when message and code match', () {
      expect(
        const ServerFailure('bad request', code: 400),
        equals(const ServerFailure('bad request', code: 400)),
      );
    });

    test('inequality when codes differ', () {
      expect(
        const ServerFailure('error', code: 400),
        isNot(equals(const ServerFailure('error', code: 500))),
      );
    });
  });

  group('ConflictFailure', () {
    test('creates instance with message only', () {
      const failure = ConflictFailure('sync conflict');
      expect(failure.message, 'sync conflict');
      expect(failure.localData, isNull);
      expect(failure.remoteData, isNull);
    });

    test('creates instance with local and remote data', () {
      const failure = ConflictFailure(
        'conflict',
        localData: {'id': '1', 'version': 1},
        remoteData: {'id': '1', 'version': 2},
      );
      expect(failure.localData, {'id': '1', 'version': 1});
      expect(failure.remoteData, {'id': '1', 'version': 2});
    });

    test('equality holds when message and data match', () {
      const a = ConflictFailure('conflict', localData: 'v1', remoteData: 'v2');
      const b = ConflictFailure('conflict', localData: 'v1', remoteData: 'v2');
      expect(a, equals(b));
    });

    test('inequality when remote data differs', () {
      const a = ConflictFailure('conflict', remoteData: 'v1');
      const b = ConflictFailure('conflict', remoteData: 'v2');
      expect(a, isNot(equals(b)));
    });
  });

  group('Failure subtype distinction', () {
    test('different subtypes with same message are not equal', () {
      const a = DatabaseFailure('error');
      const b = NetworkFailure('error');
      // Different runtime types – should not be considered equal.
      expect(a == b, isFalse);
    });
  });
}
