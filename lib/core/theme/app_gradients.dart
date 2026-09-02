import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Gradient flow tokens for Liquid Glass v2.
/// All gradients are const where possible for performance.
abstract final class AppGradients {
  // Gold flow 135deg: primary gold to earth brown
  static const goldFlow = LinearGradient(
    colors: [Color(0xFFFFB030), Color(0xFF874D14)],
    begin: Alignment(-0.9, -0.9),
    end: Alignment(0.9, 0.9),
    transform: GradientRotation(135 * math.pi / 180),
  );

  static const amberGlow = LinearGradient(
    colors: [Color(0xFFFFE3B3), Color(0xFFFFB030)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const creamFlow = LinearGradient(
    colors: [Color(0xFFF9F6F0), Color(0xFFE6DDC8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkFlow = LinearGradient(
    colors: [Color(0xFF2A2520), Color(0xFF121212)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Specular top highlight for lensing (white 0.45 -> transparent)
  static LinearGradient get specularHighlight => LinearGradient(
    colors: [Colors.white.withValues(alpha: 0.42), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradient border for glass edges (subtle sheen)
  static LinearGradient get borderSheenLight => LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.52),
      Colors.white.withValues(alpha: 0.08),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get borderSheenDark => LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.14),
      Colors.white.withValues(alpha: 0.04),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
