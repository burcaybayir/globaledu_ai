import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/constants/app_constants.dart';

class RouteTransitions {
  RouteTransitions._();

  /// Fade transition for main navigation.
  static CustomTransitionPage<void> fade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.pageTransition,
      reverseTransitionDuration: AppConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Slide from right transition for push navigation.
  static CustomTransitionPage<void> slideRight({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.pageTransition,
      reverseTransitionDuration: AppConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition for modals.
  static CustomTransitionPage<void> slideUp({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.pageTransition,
      reverseTransitionDuration: AppConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Scale + fade transition for dialogs / detail pages.
  static CustomTransitionPage<void> scaleFade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.pageTransition,
      reverseTransitionDuration: AppConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurveTween(curve: Curves.easeOutCubic)
            .animate(animation);
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0)
                .animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
