import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design System v3 canvas backgrounds (DEEN 8.2).
///
/// Paint-only layers: opaque multi-stop gradients, no blur primitives.
/// Each factory returns one [BoxDecoration]; the screen paints it on a
/// full-bleed Container behind scrolling content (Scaffold background
/// transparent, extendBody true). Gradient stops encode the described
/// glow stacks top-to-bottom so a single decoration suffices.
abstract final class CanvasGradient {
  /// Light Home canvas: cream base with warm gold glow at the top
  /// fading into cream, grounding to creamDark at the bottom edge.
  static BoxDecoration dawn() => const BoxDecoration(
    color: AppColors.cream,
    gradient: LinearGradient(
      colors: [
        Color(0xFFFFE9C4),
        AppColors.cream,
        AppColors.cream,
        AppColors.creamDark,
      ],
      stops: [0.0, 0.28, 0.72, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  /// Dark Home canvas: deep green-black with a gold glow at the top
  /// and an emerald wash at the bottom edge.
  static BoxDecoration night() => const BoxDecoration(
    color: AppColors.nightCanvasBottom,
    gradient: LinearGradient(
      colors: [
        Color(0xFF2A3A28),
        AppColors.nightCanvasTop,
        AppColors.nightCanvasBottom,
        Color(0xFF0E2A20),
      ],
      stops: [0.0, 0.3, 0.75, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  /// Calm light reader surface (token only in R1; reader adopts it in R2).
  static BoxDecoration parchment() =>
      const BoxDecoration(color: AppColors.parchment);

  /// Calm dark reader surface (token only in R1; reader adopts it in R2).
  static BoxDecoration mushafNight() =>
      const BoxDecoration(color: AppColors.mushafNight);

  /// Returns the Home canvas for the current brightness.
  static BoxDecoration forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? night() : dawn();
}
