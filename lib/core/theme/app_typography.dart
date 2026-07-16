import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // ─── Font Families ───
  static String get _headingFamily => GoogleFonts.poppins().fontFamily!;
  static String get _bodyFamily => GoogleFonts.inter().fontFamily!;

  // ─── Heading Styles ───
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
      );

  // ─── Title Styles ───
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
      );

  // ─── Body Styles ───
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      );

  // ─── Label Styles ───
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.6,
        letterSpacing: 0.5,
      );

  /// Builds the complete TextTheme for MaterialApp.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
