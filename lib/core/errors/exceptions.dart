/// Base exception class for all app exceptions.
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when a server/API request fails.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;
}

/// Thrown when there is no network connection.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
    super.stackTrace,
  });
}

/// Thrown when cached/local data is not found or invalid.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Local data not found.',
    super.code = 'CACHE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.stackTrace,
  });
}

/// Thrown when a Firebase operation fails.
class FirebaseAppException extends AppException {
  const FirebaseAppException({
    required super.message,
    super.code = 'FIREBASE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when an AI/OpenAI request fails.
class AiException extends AppException {
  const AiException({
    required super.message,
    super.code = 'AI_ERROR',
    super.stackTrace,
  });
}

/// Thrown when the user's subscription doesn't allow an action.
class SubscriptionException extends AppException {
  const SubscriptionException({
    super.message = 'This feature requires a premium subscription.',
    super.code = 'SUBSCRIPTION_ERROR',
    super.stackTrace,
  });
}

/// Thrown when a file operation fails.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when request validation fails.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.stackTrace,
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;
}

/// Thrown when a resource limit is reached.
class LimitExceededException extends AppException {
  const LimitExceededException({
    required super.message,
    super.code = 'LIMIT_EXCEEDED',
    super.stackTrace,
  });
}
