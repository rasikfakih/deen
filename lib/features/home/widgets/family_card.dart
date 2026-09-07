import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../social/providers/social_providers.dart';

/// Design v3 family circles card: first circle name, member count,
/// last activity, Open Circles CTA. Graceful guest/offline/empty state
/// with a create-first-circle CTA. Static paint, no glow.
class FamilyCirclesHomeCard extends ConsumerWidget {
  const FamilyCirclesHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circlesAsync = ref.watch(myCirclesProvider);
    final onDark = isDark ? AppColors.darkOnSurface : AppColors.textDark;

    return circlesAsync.when(
      loading: () => const DeenCard(
        child: SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => _GuestCard(onDark: onDark),
      data: (circles) {
        if (circles.isEmpty) return _GuestCard(onDark: onDark);
        final first = circles.first;
        final circleId = '${first['id']}';
        final name = '${first['name']}';
        final memberCount =
            ref.watch(circleMemberCountProvider(circleId)).valueOrNull ?? 0;
        final activity =
            ref.watch(lastLeaderboardUpdatedProvider(circleId)).valueOrNull ??
            'No activity yet';

        return Semantics(
          label: 'Family circles',
          value: '$name, $memberCount members, $activity',
          child: DeenCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.group_outlined,
                    color: AppColors.emeraldDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.titleMedium.copyWith(
                          color: onDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$memberCount members • $activity',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Open family circles',
                  child: TextButton(
                    onPressed: () => context.push('/family-circles'),
                    child: Text(
                      'Open',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.emeraldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onDark});

  final Color onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Family circles',
      value: 'No circles yet',
      child: DeenCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.group_outlined,
                color: AppColors.emeraldDark,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Circles',
                    style: AppTypography.titleMedium.copyWith(color: onDark),
                  ),
                  Text(
                    'Grow together — create your first private circle.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'Create family circle',
              child: TextButton(
                onPressed: () => context.push('/family-circles'),
                child: Text(
                  'Create',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.emeraldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
