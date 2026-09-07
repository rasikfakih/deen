import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../quran/data/quran_repository.dart';
import '../../quran/providers/quran_providers.dart';

/// Design v3 Ayah of the Day: deterministic pick from verified data
/// (dayOfYear % length). Verbatim Arabic (one line, RTL) + translation
/// (two lines) + numeric reference. Static paint, no glow.
class AyahOfDayCard extends ConsumerWidget {
  const AyahOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ayahAsync = ref.watch(ayahOfDayProvider);

    return ayahAsync.when(
      loading: () => const DeenCard(
        child: SizedBox(
          height: 96,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => DeenCard(
        child: Text(
          'Ayah of the day is unavailable offline right now.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
      data: (QuranAyah? ayah) {
        if (ayah == null) {
          return DeenCard(
            child: Text(
              'Ayah of the day is unavailable offline right now.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }
        final reference = 'Surah ${ayah.surahId} • Ayah ${ayah.ayahId}';
        return Semantics(
          label: 'Ayah of the day, $reference',
          child: DeenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayah of the Day',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                Semantics(
                  excludeSemantics: true,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      ayah.arabic,
                      style: AppTypography.arabicStyle(
                        fontSize: 20,
                        height: 1.8,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXS),
                Semantics(
                  excludeSemantics: true,
                  child: Text(
                    ayah.english,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXS),
                Text(
                  reference,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w600,
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
