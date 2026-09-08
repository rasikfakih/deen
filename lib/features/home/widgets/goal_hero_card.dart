import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../../shared/widgets/icons/deen_symbol_effects.dart';

/// Design v3 goal hero: gold gradient card with progress bar, ayah count +
/// percent labels, numeric last-read line, Continue Reading CTA.
/// Dark-on-gold text for AA contrast. Static paint, no glow.
class GoalHeroCard extends StatelessWidget {
  const GoalHeroCard({
    super.key,
    required this.current,
    required this.target,
    required this.lastSurahId,
    required this.lastAyahId,
  });

  final int current;
  final int target;
  final int? lastSurahId;
  final int? lastAyahId;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    const onGold = AppColors.textDark;
    const onGoldMuted = AppColors.earthBrownDark;
    final lastLine = lastSurahId != null && lastAyahId != null
        ? 'Surah $lastSurahId • Ayah $lastAyahId'
        : 'Not started yet — every journey begins with one ayah';

    return Semantics(
      label: 'Daily goal',
      value: '$current of $target ayahs, $percent percent',
      child: DeenHeroCard(
        variant: DeenHeroVariant.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Daily Goal',
                  style: AppTypography.titleLarge.copyWith(
                    color: onGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    '$current / $target ayahs',
                    style: AppTypography.labelMedium.copyWith(
                      color: onGold,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXS),
                Text(
                  '$percent%',
                  style: AppTypography.labelMedium.copyWith(
                    color: onGoldMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Semantics(
              excludeSemantics: true,
              child: DeenAnimatedIcon(
                effect: DeenSymbolEffect.drawOn,
                replayKey: 'goal-bar',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.earthBrown.withValues(
                      alpha: 0.25,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              lastLine,
              style: AppTypography.bodySmall.copyWith(color: onGoldMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Continue reading',
                child: ElevatedButton(
                  onPressed: () => context.go('/quran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.earthBrownDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                  ),
                  child: const Text('Continue Reading'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
