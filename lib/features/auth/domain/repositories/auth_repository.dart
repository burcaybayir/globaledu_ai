import 'package:dartz/dartz.dart';
import 'package:globaledu_ai/core/errors/failures.dart';
import 'package:globaledu_ai/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and display name.
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Sign out the current user.
  Future<Either<Failure, void>> signOut();

  /// Send password reset email.
  Future<Either<Failure, void>> resetPassword(String email);

  /// Get the current authenticated user.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
