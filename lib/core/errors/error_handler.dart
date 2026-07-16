import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:globaledu_ai/core/errors/exceptions.dart';
import 'package:globaledu_ai/core/errors/failures.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 2, lineLength: 80),
);

class ErrorHandler {
  ErrorHandler._();

  /// Converts exceptions from data layer into domain Failures.
  static Failure handleException(dynamic exception) {
    _logger.e('Error caught', error: exception);

    if (exception is AppException) {
      return _mapAppException(exception);
    }

    if (exception is DioException) {
      return _mapDioException(exception);
    }

    if (exception is FirebaseAuthException) {
      return AuthFailure(
        message: _mapFirebaseAuthError(exception.code),
        code: exception.code,
      );
    }

    if (exception is FirebaseException) {
      return FirebaseFailure(
        message: exception.message ?? 'Firebase error occurred.',
        code: exception.code,
      );
    }

    if (exception is TimeoutException) {
      return const ServerFailure(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }

    if (exception is FormatException) {
      return ServerFailure(
        message: 'Invalid data format: ${exception.message}',
        code: 'FORMAT_ERROR',
      );
    }

    return UnknownFailure(
      message: exception.toString(),
    );
  }

  static Failure _mapAppException(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        code: exception.code,
        statusCode: exception.statusCode,
      );
    }
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }
    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }
    if (exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }
    if (exception is AiException) {
      return AiFailure(message: exception.message, code: exception.code);
    }
    if (exception is SubscriptionException) {
      return SubscriptionFailure(message: exception.message);
    }
    if (exception is StorageException) {
      return StorageFailure(message: exception.message);
    }
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }
    return UnknownFailure(message: exception.message);
  }

  static Failure _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure(
          message: 'Connection timed out. Please try again.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = _extractErrorMessage(exception.response);
        return ServerFailure(
          message: message,
          statusCode: statusCode,
          code: 'HTTP_$statusCode',
        );
      case DioExceptionType.cancel:
        return const ServerFailure(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
        );
      default:
        return ServerFailure(
          message: exception.message ?? 'Network error occurred.',
          code: 'DIO_ERROR',
        );
    }
  }

  static String _extractErrorMessage(Response<dynamic>? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;
      return (data['error']?['message'] as String?) ??
          (data['message'] as String?) ??
          'Server error occurred.';
    }
    return 'Server error: ${response?.statusCode}';
  }

  static String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credentials are invalid or expired.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error: $code';
    }
  }

  /// User-friendly error message for UI display.
  static String getUserMessage(Failure failure) {
    return failure.message;
  }
}
