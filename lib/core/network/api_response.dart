import 'package:dartz/dartz.dart';
import 'package:globaledu_ai/core/errors/failures.dart';

/// Wrapper for API responses with Either pattern.
class ApiResponse<T> {
  const ApiResponse._({
    this.data,
    this.failure,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) => ApiResponse._(
        data: data,
        isSuccess: true,
      );

  factory ApiResponse.error(Failure failure) => ApiResponse._(
        failure: failure,
        isSuccess: false,
      );

  final T? data;
  final Failure? failure;
  final bool isSuccess;

  /// Converts to Either for use-case compatibility.
  Either<Failure, T> toEither() {
    if (isSuccess && data != null) {
      return Right(data as T);
    }
    return Left(failure ?? const UnknownFailure());
  }

  /// Maps data if successful.
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return ApiResponse.success(mapper(data as T));
    }
    return ApiResponse.error(failure ?? const UnknownFailure());
  }
}

/// Type alias for the standard repository return type.
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type alias for void results.
typedef ResultVoid = ResultFuture<void>;
