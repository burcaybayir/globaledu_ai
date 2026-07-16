import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/features/auth/presentation/providers/auth_provider.dart';

/// Auth guard that redirects based on authentication state.
class RouteGuards {
  RouteGuards._();

  static FutureOr<String?> authGuard(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) {
    final authState = ref.read(authStateProvider);

    return authState.when(
      data: (user) {
        final isLoggedIn = user != null;
        final isAuthRoute = state.matchedLocation == RouteNames.loginPath ||
            state.matchedLocation == RouteNames.registerPath ||
            state.matchedLocation == RouteNames.forgotPasswordPath;
        final isOnboardingRoute =
            state.matchedLocation == RouteNames.welcomePath;
        final isSplash = state.matchedLocation == RouteNames.splashPath;

        // If on splash, redirect based on auth state
        if (isSplash) {
          return isLoggedIn
              ? RouteNames.shellPath
              : RouteNames.welcomePath;
        }

        // If not logged in and not on auth route, redirect to welcome
        if (!isLoggedIn && !isAuthRoute && !isOnboardingRoute) {
          return RouteNames.welcomePath;
        }

        // If logged in and on auth route, redirect to home
        if (isLoggedIn && isAuthRoute) {
          return RouteNames.shellPath;
        }

        // No redirect needed
        return null;
      },
      loading: () => null,
      error: (_, __) => RouteNames.loginPath,
    );
  }
}
