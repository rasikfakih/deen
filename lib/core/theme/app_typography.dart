import 'package:flutter/material.dart';

/// Typography tokens per DEEN Section 8.
///
/// Latin UI - Poppins bundled via assets/fonts with OFL.
/// Arabic UI - Tajawal bundled via assets/fonts.
/// Mushaf text - Amiri Quran / KFGQPC Uthman Taha (handled separately).
///
/// Fonts are declared in pubspec.yaml and bundled as assets. If the
/// placeholder TTF files have not yet been replaced with real OFL files,
/// Flutter will safely fallback to system fonts without crashing.
abstract final class AppTypography {
  // Base text style helpers - Poppins is the single source of truth for Latin.
  static TextStyle _poppins({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Display - heroic, use sparingly (sacred screens minimal, playful screens celebratory).
  static TextStyle displayLarge = _poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static TextStyle displayMedium = _poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static TextStyle displaySmall = _poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Headline - section headers.
  static TextStyle headlineLarge = _poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static TextStyle headlineMedium = _poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static TextStyle headlineSmall = _poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title - cards, list tiles, app bars.
  static TextStyle titleLarge = _poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );
  static TextStyle titleMedium = _poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  static TextStyle titleSmall = _poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // Body - primary reading.
  static TextStyle bodyLarge = _poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle bodyMedium = _poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle bodySmall = _poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Label - buttons, captions, overlines.
  static TextStyle labelLarge = _poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );
  static TextStyle labelMedium = _poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );
  static TextStyle labelSmall = _poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );

  /// Full TextTheme for ThemeData.
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

  // ---------------------------------------------------------------------------
  // Arabic - Tajawal bundled via assets/fonts. For RTL later, wrap with Directionality.
  // ---------------------------------------------------------------------------

  /// Returns a Tajawal style for Arabic UI labels. Pair with Poppins metrics.
  static TextStyle arabicStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.6,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  /// Arabic TextTheme variant - use when locale is ar.
  static TextTheme get arabicTextTheme => TextTheme(
    displayLarge: arabicStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    headlineLarge: arabicStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: arabicStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    bodyLarge: arabicStyle(fontSize: 16, height: 1.7),
    bodyMedium: arabicStyle(fontSize: 14, height: 1.6),
    labelLarge: arabicStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
  );

  // Mushaf text mode (Amiri Quran / KFGQPC) is handled at reader widget level,
  // not here - it requires specialized line height and justification.
}
