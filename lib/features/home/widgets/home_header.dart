import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deen_icons.dart';
import '../../../shared/widgets/icons/deen_symbol_effects.dart';

/// Design v6 Home header: lives on the night band, so text is cream.
/// Avatar carries a 2px gold ring. Truncation is width-aware: below
/// 360dp the greeting may ellipsize to one line; at 360dp and above the
/// subline gets its own full-width line with no truncation.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.greeting,
    required this.greeting2,
    required this.streakCount,
    required this.todayCount,
    required this.targetCount,
    required this.goalUnit,
  });

  final String? userName;
  final String greeting;
  final String greeting2;
  final int streakCount;
  final int todayCount;
  final int targetCount;
  final String goalUnit;

  @override
  Widget build(BuildContext context) {
    final name = (userName ?? '').trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Semantics(
      label: 'Home header',
      value: '$greeting${name.isEmpty ? '' : ', $name'}',
      child: Builder(
        builder: (context) {
          // Screen width (not column width): the 360dp rule is about the
          // device class, so measure the screen via MediaQuery.
          final narrow = MediaQuery.sizeOf(context).width < 360;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Profile avatar',
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                    child: Text(
                      initial,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting${name.isEmpty ? '' : ', $name'}',
                      key: const ValueKey('home-greeting'),
                      style: AppTypography.headlineSmall.copyWith(
                        color: const Color(0xFFFFF8EE),
                      ),
                      maxLines: narrow ? 1 : null,
                      overflow: narrow
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                    Text(
                      greeting2,
                      key: const ValueKey('home-subline'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFFC9BBA8),
                      ),
                      maxLines: narrow ? 1 : null,
                      overflow: narrow
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                    const SizedBox(height: AppSpacing.spaceSM),
                    Row(
                      children: [
                        Semantics(
                          label: 'Current streak',
                          value: '$streakCount days',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSM,
                              vertical: AppSpacing.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DeenAnimatedIcon(
                                  asset: DeenIcons.ic_streak,
                                  size: 14,
                                  color: AppColors.gold,
                                  effect: streakCount > 0
                                      ? DeenSymbolEffect.pulse
                                      : DeenSymbolEffect.none,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$streakCount',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: const Color(0xFFFFF8EE),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spaceXS),
                        Semantics(
                          label: 'Today goal progress',
                          value: '$todayCount of $targetCount $goalUnit',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSM,
                              vertical: AppSpacing.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Text(
                              '$todayCount/$targetCount',
                              style: AppTypography.labelMedium.copyWith(
                                color: const Color(0xFFFFF8EE),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Open settings',
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  color: const Color(0xFFFFF8EE),
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Settings',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
