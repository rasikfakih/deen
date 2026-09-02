import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/settings/providers/settings_providers.dart';
import 'glass_metrics.dart';

enum DeenGlassVariant { regular, clear }

/// Liquid Glass surface — ClipRRect + BackdropFilter blur, adaptive tint,
/// gradient border, specular top highlight, soft shadow.
/// Max one BackdropFilter per screen region, wrapped in RepaintBoundary.
/// Clear variant auto-adds dimming overlay beneath content.
class DeenGlass extends ConsumerWidget {
  const DeenGlass({
    super.key,
    required this.child,
    this.variant = DeenGlassVariant.regular,
    this.borderRadius = AppSpacing.radiusLG,
    this.blurSigma = AppSpacing.glassBlurSigma,
    this.padding,
    this.margin,
  });

  final Widget child;
  final DeenGlassVariant variant;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    final effectiveSigma = GlassMetrics.effectiveSigma(blurSigma, elderly);

    final tint = variant == DeenGlassVariant.clear
        ? (isDark
              ? AppColors.glassDark.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.52))
        : (isDark ? AppColors.glassDark : AppColors.glassLight);

    final borderColor = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: AppSpacing.glassBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: AppSpacing.elevationLG,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dimming layer for clear variant
          if (variant == DeenGlassVariant.clear)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          // Specular top highlight - lensing via gradient edge, not plain blur
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: elderly ? 0.22 : 0.42),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    return RepaintBoundary(
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveSigma,
              sigmaY: effectiveSigma,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
