import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';

/// Design v3 daily challenge: dark card with today's ayah target and
/// progress from DailyReads. White-on-dark text. Static paint, no glow.
class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    super.key,
    required this.targetAyahs,
    required this.todayAyahs,
  });

  final int targetAyahs;
  final int todayAyahs;

  @override
  Widget build(BuildContext context) {
    final progress = targetAyahs <= 0
        ? 0.0
        : (todayAyahs / targetAyahs).clamp(0.0, 1.0);
    final done = todayAyahs >= targetAyahs && targetAyahs > 0;

    return Semantics(
      label: 'Daily challenge',
      value: done
          ? 'Completed, $todayAyahs of $targetAyahs ayahs'
          : '$todayAyahs of $targetAyahs ayahs read',
      child: DeenHeroCard(
        variant: DeenHeroVariant.night,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Challenge',
              style: AppTypography.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              done
                  ? 'Challenge complete — mashaAllah, see you tomorrow.'
                  : 'Read $targetAyahs ayahs today to complete the challenge.',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Semantics(
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Start daily challenge',
                child: ElevatedButton(
                  onPressed: () => context.go('/quran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                  ),
                  child: Text(done ? 'Read More' : 'Start'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
