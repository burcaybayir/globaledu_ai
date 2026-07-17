import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Palette (Apple-inspired + Violet brand) ───
  static const Color primary = Color(0xFF5E5CE6);        // System indigo
  static const Color primaryLight = Color(0xFF7D7AFF);
  static const Color primaryDark = Color(0xFF4240C4);
  static const Color primarySurface = Color(0xFFEEEDFF);

  static const Color secondary = Color(0xFF32ADE6);      // Sky blue
  static const Color secondaryLight = Color(0xFF5BC4F0);
  static const Color secondaryDark = Color(0xFF1A8EC4);

  static const Color accent = Color(0xFFFF6B6B);         // Coral
  static const Color accentOrange = Color(0xFFFF9F0A);   // System orange
  static const Color accentMint = Color(0xFF00D2A0);     // Mint
  static const Color accentGold = Color(0xFFFFD60A);     // Gold

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5E5CE6), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF32ADE6), Color(0xFF5E5CE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9F0A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF00D2A0), Color(0xFF32ADE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD60A), Color(0xFFFF9F0A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF0D0D1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF32ADE6), Color(0xFF00D2A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Semantic ───
  static const Color success = Color(0xFF30D158);        // Apple green
  static const Color successLight = Color(0xFFE5F9ED);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFFF453A);          // Apple red
  static const Color errorLight = Color(0xFFFFEBEA);
  static const Color info = Color(0xFF32ADE6);

  // ─── Light Theme ───
  static const Color lightBackground = Color(0xFFF5F5F7);   // Apple gray
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF2F2F7);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightSeparator = Color(0xFFC6C6C8);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF6E6E73);  // Apple secondary
  static const Color lightTextTertiary = Color(0xFFAEAEB2);
  static const Color lightFill = Color(0xFFE5E5EA);

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF000000);     // Pure black (OLED)
  static const Color darkSurface = Color(0xFF1C1C1E);        // Apple dark
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkSurfaceElevated = Color(0xFF3A3A3C);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkSeparator = Color(0xFF545456);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAEAEB2);   // Apple secondary
  static const Color darkTextTertiary = Color(0xFF6E6E73);
  static const Color darkFill = Color(0xFF3A3A3C);

  // ─── Glass Effect ───
  static Color glassLight = Colors.white.withOpacity(0.72);
  static Color glassDark = Colors.white.withOpacity(0.07);
  static Color glassBorderLight = Colors.white.withOpacity(0.5);
  static Color glassBorderDark = Colors.white.withOpacity(0.12);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // ─── Application Status ───
  static const Color statusPreparing = Color(0xFFAEAEB2);
  static const Color statusSubmitted = Color(0xFF32ADE6);
  static const Color statusReview = Color(0xFFFF9F0A);
  static const Color statusInterview = Color(0xFF5E5CE6);
  static const Color statusOffer = Color(0xFF30D158);
  static const Color statusAccepted = Color(0xFF30D158);
  static const Color statusRejected = Color(0xFFFF453A);
  static const Color statusWithdrawn = Color(0xFF6E6E73);

  // ─── Match Score ───
  static const Color matchHigh = Color(0xFF30D158);
  static const Color matchMedium = Color(0xFFFF9F0A);
  static const Color matchLow = Color(0xFFFF453A);
}
