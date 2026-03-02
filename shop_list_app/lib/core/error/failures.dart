import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
/// Failures are returned from repositories and use cases via [Either<Failure, T>].
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure caused by a local SQLite / Drift database error.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure caused by a form or business-rule validation error.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure caused by a network / connectivity error.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure caused when a requested resource does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure caused by a local cache error.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure returned when the remote server responds with an error.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Failure produced when a sync conflict is detected between local and remote data.
class ConflictFailure extends Failure {
  /// The local version of the conflicting entity (nullable).
  final Object? localData;

  /// The remote version of the conflicting entity (nullable).
  final Object? remoteData;

  const ConflictFailure(
    super.message, {
    this.localData,
    this.remoteData,
  });

  @override
  List<Object?> get props => [message, code, localData, remoteData];
}
