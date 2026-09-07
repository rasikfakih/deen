import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../quran/providers/quran_providers.dart';

/// Design v3 quick chips: last-read surahs (numeric labels until R1.5)
/// plus three default entry points. Tap sets LastRead to the surah opening
/// and routes to the reader (which restores that position).
class SurahChips extends ConsumerWidget {
  const SurahChips({super.key});

  /// Default entry surahs (IDs only in R1; names arrive with R1.5 metadata).
  static const defaultSurahs = <int>[2, 36, 67];

  Future<void> _openSurah(
    BuildContext context,
    WidgetRef ref,
    int surahId,
  ) async {
    final updater = ref.read(updateLastReadProvider);
    await updater(surahId: surahId, ayahId: 1);
    if (context.mounted) context.go('/quran');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentsAsync = ref.watch(recentSurahsProvider);
    final recents = recentsAsync.valueOrNull ?? const <int>[];
    final ids = <int>[...recents];
    for (final d in defaultSurahs) {
      if (!ids.contains(d)) ids.add(d);
    }

    return Semantics(
      label: 'Quick surah shortcuts',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final id in ids)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.spaceSM),
                child: Semantics(
                  button: true,
                  label: 'Open Surah $id',
                  child: ActionChip(
                    label: Text('Surah $id'),
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.white.withValues(alpha: 0.75),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkOutlineVariant
                          : AppColors.lightOutlineVariant,
                    ),
                    onPressed: () => _openSurah(context, ref, id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
