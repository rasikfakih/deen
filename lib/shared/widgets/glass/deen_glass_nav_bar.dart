import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/deen_icons.dart';
import '../../../features/settings/providers/settings_providers.dart';
import 'deen_glass.dart';
import 'deen_gradient_icon.dart';
import 'glass_metrics.dart';

/// Floating Liquid Glass bottom navigation.
/// Margin 16, radius 28, blur, gradient border, internal glow on tap.
/// Selected icon rendered with gradient via ShaderMask srcIn.
class DeenGlassNavBar extends ConsumerWidget {
  const DeenGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: DeenIcons.ic_home, label: 'Home'),
    (icon: DeenIcons.ic_quran, label: 'Quran'),
    (icon: DeenIcons.ic_qibla, label: 'Qibla'),
    (icon: DeenIcons.ic_tasbih, label: 'Tasbih'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    final blurSigma = GlassMetrics.effectiveSigma(18, elderly);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.navFloatingMargin,
          0,
          AppSpacing.navFloatingMargin,
          AppSpacing.navFloatingMargin,
        ),
        child: RepaintBoundary(
          child: DeenGlass(
            variant: DeenGlassVariant.regular,
            borderRadius: AppSpacing.navRadius,
            blurSigma: blurSigma,
            child: Container(
              height: AppSpacing.navHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSM,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  final isSelected = i == currentIndex;
                  final item = _items[i];
                  final iconWidget = isSelected
                      ? DeenGradientIcon(
                          asset: item.icon,
                          size: 20,
                          gradient: AppGradients.goldFlow,
                        )
                      : SvgPicture.asset(
                          item.icon,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            isDark
                                ? const Color(0xFF9E9589)
                                : AppColors.textMuted,
                            BlendMode.srcIn,
                          ),
                        );

                  Widget button = InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.gold.withValues(alpha: 0.16)
                                  : AppColors.gold.withValues(alpha: 0.14))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.gold.withValues(alpha: 0.22),
                                width: 0.8,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          iconWidget,
                          const SizedBox(height: 1),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.textDark)
                                  : (isDark
                                        ? const Color(0xFF9E9589)
                                        : AppColors.textMuted),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isSelected && !elderly) {
                    button = button
                        .animate(key: ValueKey('nav-$i'))
                        .shimmer(
                          duration: 420.ms,
                          color: AppColors.gold.withValues(alpha: 0.28),
                        );
                  }

                  return Expanded(child: Center(child: button));
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
