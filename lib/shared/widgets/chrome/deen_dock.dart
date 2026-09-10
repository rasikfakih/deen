import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/deen_icons.dart';
import '../../providers/display_providers.dart';
import '../icons/deen_symbol_effects.dart';

/// Deen Dock (Design v6, DEEN 8.4). Opaque bottom navigation — no blur.
///
/// Opaque surface (white light / #1E1B16 dark), radius 28, diffuse shadow.
/// Selected item: goldFlow gradient pill, dark-on-gold label. Quintic
/// transitions, bounce on selection, RepaintBoundary kept.
class DeenDock extends ConsumerWidget {
  const DeenDock({super.key, required this.currentIndex, required this.onTap});

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
    final bottomPad = math.max(
      AppSpacing.navFloatingMargin - 4,
      MediaQuery.viewPaddingOf(context).bottom,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPad),
      child: RepaintBoundary(
        child: Container(
          height: AppSpacing.navHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSM,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.navRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 24,
                offset: Offset(0, 8),
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
                            ? const Color(0xFFC9BBA8)
                            : const Color(0xFF6B6257),
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
                        gradient: isSelected ? AppGradients.goldFlow : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
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
                                        ? const Color(0xFFFFF8EE)
                                        : const Color(0xFF4A2E08))
                                  : (isDark
                                        ? const Color(0xFFC9BBA8)
                                        : const Color(0xFF6B6257)),
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
    );
  }
}
