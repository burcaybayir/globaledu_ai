import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9B94FF);
  static const Color primaryDark = Color(0xFF4A42E0);
  static const Color primarySurface = Color(0xFFEEEDFF);

  static const Color secondary = Color(0xFF00D2FF);
  static const Color secondaryLight = Color(0xFF67E8FF);
  static const Color secondaryDark = Color(0xFF00A3CC);

  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8FA6);
  static const Color accentDark = Color(0xFFE04466);

  // ─── Gradient Definitions ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF9A76)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF3D3D);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── Light Theme Colors ───
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF2F3F8);
  static const Color lightBorder = Color(0xFFE8E9F1);
  static const Color lightTextPrimary = Color(0xFF1A1D26);
  static const Color lightTextSecondary = Color(0xFF6B7080);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // ─── Dark Theme Colors ───
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkBorder = Color(0xFF2D2D4A);
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7080);

  // ─── Glass Effect ───
  static Color glassLight = Colors.white.withOpacity(0.15);
  static Color glassDark = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // ─── Application Status Colors ───
  static const Color statusPreparing = Color(0xFF9CA3AF);
  static const Color statusSubmitted = Color(0xFF2196F3);
  static const Color statusReview = Color(0xFFFFB300);
  static const Color statusInterview = Color(0xFF9B59B6);
  static const Color statusOffer = Color(0xFF00C853);
  static const Color statusAccepted = Color(0xFF00C853);
  static const Color statusRejected = Color(0xFFFF3D3D);
  static const Color statusWithdrawn = Color(0xFF6B7080);

  // ─── Scholarship Match Colors ───
  static const Color matchHigh = Color(0xFF00C853);
  static const Color matchMedium = Color(0xFFFFB300);
  static const Color matchLow = Color(0xFFFF6584);
}
