import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';

/// Design v3 card system (DEEN 8.2). Opaque surfaces only — never glass,
/// never blurred. Radius 24, soft shadow, subtle inner top highlight.
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
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: AppSpacing.elevationSM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.2,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXL),
                    topRight: Radius.circular(AppSpacing.radiusXL),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
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
            blurRadius: AppSpacing.elevationLG,
            offset: Offset(0, 4),
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
