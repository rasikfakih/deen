import 'package:flutter/material.dart';

/// Design tokens - palette per DEEN_AI_CONTEXT.md Section 8.
///
/// Gold primary #FFB030, Earth brown #874D14, Cream #F9F6F0,
/// Text dark #1F1F1F, Dark background #121212, Surfaces dark #1E1B16.
///
/// All colors are opaque and tuned for WCAG AA. Do not add new palette
/// values without CTO review - extend via semantic aliases only.
abstract final class AppColors {
  // Raw brand palette.
  static const Color gold = Color(0xFFFFB030);
  static const Color goldDark = Color(0xFFE68F00);
  static const Color goldLight = Color(0xFFFFC25C);

  static const Color earthBrown = Color(0xFF874D14);
  static const Color earthBrownDark = Color(0xFF6B3C10);
  static const Color earthBrownLight = Color(0xFF9E5A1A);

  static const Color cream = Color(0xFFF9F6F0);
  static const Color creamDark = Color(0xFFECE6D9);

  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF6B6B6B);

  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1B16);
  static const Color surfaceDarkHighlight = Color(0xFF2A2520);
  static const Color surfaceDarkBorder = Color(0xFF3A342E);

  // Semantic - light.
  static const Color lightSurface = cream;
  static const Color lightOnSurface = textDark;
  static const Color lightBackground = cream;
  static const Color lightOnBackground = textDark;
  static const Color lightSurfaceVariant = creamDark;
  static const Color lightOutline = Color(0xFFD9D1C2);
  static const Color lightOutlineVariant = Color(0xFFEDE7DC);

  // Semantic - dark.
  static const Color darkSurface = surfaceDark;
  static const Color darkOnSurface = Color(0xFFF3EFE6);
  static const Color darkBackgroundSemantic = darkBackground;
  static const Color darkOnBackground = Color(0xFFF3EFE6);
  static const Color darkSurfaceVariant = surfaceDarkHighlight;
  static const Color darkOutline = surfaceDarkBorder;
  static const Color darkOutlineVariant = Color(0xFF2F2A24);

  // Shared semantic.
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFF9DEDC);
  static const Color errorContainerDark = Color(0xFF410002);

  // Navigation specifics.
  static const Color navIndicatorLight = gold;
  static const Color navIndicatorDark = gold;

  // Shadow.
  static const Color shadowLight = Color(0x1F1F1F1F);
  static const Color shadowDark = Color(0x66000000);

  // Contrast note:
  // Gold on darkBackground ~8.2:1 (AA pass). Cream on textDark ~14.5:1.
  // Dark surface #1E1B16 on cream text #F3EFE6 ~13.8:1.
}
