import 'package:equatable/equatable.dart';

/// Base failure class for domain layer error representation.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Local data not found.',
    super.code = 'CACHE_ERROR',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code = 'FIREBASE_ERROR',
  });
}

class AiFailure extends Failure {
  const AiFailure({
    required super.message,
    super.code = 'AI_ERROR',
  });
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure({
    super.message = 'This feature requires a premium subscription.',
    super.code = 'SUBSCRIPTION_ERROR',
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code = 'STORAGE_ERROR',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
  });
}
