import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Gradient fade for content scrolling beneath glass bars.
/// Hard style for pinned headers (shorter, more opaque).
/// Heights are tokens in AppSpacing (hard 24, soft 32) per DEEN 8.1.
/// QA note: fade heights must be re-evaluated on a physical device.
class DeenScrollEdgeFade extends StatelessWidget {
  const DeenScrollEdgeFade({
    super.key,
    this.hard = false,
    this.height,
    this.isTop = true,
  });

  final bool hard;
  final double? height;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? AppColors.darkBackgroundSemantic
        : AppColors.lightBackground;
    return IgnorePointer(
      child: Container(
        height:
            height ??
            (hard ? AppSpacing.scrollEdgeHard : AppSpacing.scrollEdgeSoft),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isTop
                ? (hard
                      ? [base, base.withValues(alpha: 0.0)]
                      : [
                          base.withValues(alpha: 0.92),
                          base.withValues(alpha: 0.0),
                        ])
                : (hard
                      ? [base.withValues(alpha: 0.0), base]
                      : [
                          base.withValues(alpha: 0.0),
                          base.withValues(alpha: 0.92),
                        ]),
            begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
