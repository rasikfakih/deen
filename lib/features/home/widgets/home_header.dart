import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Design v3 Home header: avatar initial, greeting + name, streak flame
/// chip, goal badge (today/target), settings gear. Static paint, no glow.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = (userName ?? '').trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final onDark = isDark ? AppColors.darkOnSurface : AppColors.textDark;

    return Semantics(
      label: 'Home header',
      value: '$greeting${name.isEmpty ? '' : ', $name'}',
      child: Row(
        children: [
          Semantics(
            label: 'Profile avatar',
            excludeSemantics: true,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
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
                  style: AppTypography.headlineSmall.copyWith(color: onDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  greeting2,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: AppColors.goldDark,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$streakCount',
                    style: AppTypography.labelMedium.copyWith(
                      color: onDark,
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
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkOutlineVariant
                      : AppColors.lightOutlineVariant,
                ),
              ),
              child: Text(
                '$todayCount/$targetCount',
                style: AppTypography.labelMedium.copyWith(
                  color: onDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Open settings',
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: onDark,
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
    );
  }
}
