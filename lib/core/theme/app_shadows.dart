import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';

class AppShadows {
  AppShadows._();

  // ─── Light Theme Shadows ───
  static List<BoxShadow> get cardLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get bottomNavLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  // ─── Dark Theme Shadows ───
  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Colored Shadows ───
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get successGlow => [
        BoxShadow(
          color: AppColors.success.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
