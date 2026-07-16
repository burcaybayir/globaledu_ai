import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/core/config/firebase_guard.dart';
import 'package:globaledu_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:globaledu_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:globaledu_ai/features/auth/domain/entities/user_entity.dart';
import 'package:globaledu_ai/features/auth/domain/repositories/auth_repository.dart';

// ─── Repository Provider (lazy — only created when Firebase is ready) ───
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  if (!FirebaseGuard.isInitialized) return null;
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(),
  );
});

// ─── Auth State Stream ───
final authStateProvider = StreamProvider<User?>((ref) {
  if (!FirebaseGuard.isInitialized) {
    // Firebase not initialized — demo mode, always unauthenticated
    return Stream.value(null);
  }
  return FirebaseAuth.instance.authStateChanges();
});

// ─── Current User Provider ───
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.valueOrNull == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  if (repo == null) return null;

  final result = await repo.getCurrentUser();
  return result.fold((failure) => null, (user) => user);
});

// ─── Auth Notifier ───
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  final bool isLoading;
  final UserEntity? user;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository? _repository;

  Future<bool> signInWithEmail(String email, String password) async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Firebase not configured. Please run flutterfire configure.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository!.signInWithEmail(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Firebase not configured.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository!.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Firebase not configured.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository!.signInWithGoogle();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repository?.signOut();
    state = const AuthState();
  }

  Future<bool> resetPassword(String email) async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Firebase not configured.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository!.resetPassword(email);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
