import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';

/// Design v6 card system (DEEN 8.2 + 8.4). Opaque surfaces, separation via
/// shadow only: no top hairline, no outline borders. Radius 24.
class DeenCard extends StatelessWidget {
  const DeenCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Gradient hero card variant for emphasis modules (goal, challenge).
enum DeenHeroVariant { gold, emerald, night }

class DeenHeroCard extends StatelessWidget {
  const DeenHeroCard({
    super.key,
    required this.child,
    this.variant = DeenHeroVariant.gold,
    this.padding,
  });

  final Widget child;
  final DeenHeroVariant variant;
  final EdgeInsetsGeometry? padding;

  Gradient get _gradient => switch (variant) {
    DeenHeroVariant.gold => AppGradients.goldFlow,
    DeenHeroVariant.emerald => AppGradients.emeraldFlow,
    DeenHeroVariant.night => AppGradients.nightFlow,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Radial gold glow spot behind a primary element (dial, orb).
/// Paint-only DecoratedBox; size yourself with SizedBox/Positioned.
class DeenGlowSpot extends StatelessWidget {
  const DeenGlowSpot({super.key, this.diameter = 280, this.opacity = 0.25});

  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.gold.withValues(alpha: opacity),
              AppColors.gold.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
