import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/deen_icons.dart';
import '../../providers/display_providers.dart';
import '../icons/deen_symbol_effects.dart';
import 'glass_metrics.dart';

/// Liquid glass bottom navigation (Design v5).
///
/// Ultra-transparent base (3% tint, theme-aware), single BackdropFilter
/// wrapped in RepaintBoundary, specular 1px top line, diffuse gold
/// indicator under the selected item. All transitions quintic.
/// Glass stays on the navigation layer only.
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
    final themeMode = ref.watch(themeModeProvider).valueOrNull;
    final isDark = themeMode != null
        ? themeMode == ThemeMode.dark
        : Theme.of(context).brightness == Brightness.dark;
    final elderly = ref.watch(elderlyModeProvider).valueOrNull ?? false;
    final blurSigma = GlassMetrics.effectiveSigma(16, elderly);
    final bottomPad = math.max(
      AppSpacing.navFloatingMargin,
      MediaQuery.viewPaddingOf(context).bottom,
    );

    // 3% theme-aware base tint; sheen + specular + shadow carry definition.
    final glassBase = isDark
        ? Colors.black.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.03);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.navFloatingMargin,
        0,
        AppSpacing.navFloatingMargin,
        bottomPad,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.navRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              height: AppSpacing.navHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSM,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: glassBase,
                borderRadius: BorderRadius.circular(AppSpacing.navRadius),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.shadowDark
                        : AppColors.shadowLight,
                    blurRadius: AppSpacing.elevationLG,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  final isSelected = i == currentIndex;
                  final item = _items[i];
                  final iconWidget = isSelected
                      ? DeenAnimatedIcon(
                          key: ValueKey('nav-icon-$i'),
                          asset: item.icon,
                          size: 20,
                          gradient: AppGradients.goldFlow,
                          effect: DeenSymbolEffect.bounce,
                          replayKey: currentIndex,
                          semanticLabel: '${item.label} tab, selected',
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

                  return Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () => onTap(i),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutQuint,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            // Diffuse gold wash (goldFlow stops at 0.18).
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.gold.withValues(alpha: 0.18),
                                      AppColors.earthBrown.withValues(
                                        alpha: 0.18,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.22,
                                    ),
                                    width: 0.8,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              iconWidget,
                              const SizedBox(height: 1),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint,
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
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
