import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/screen_insets.dart';
import '../../../shared/widgets/chrome/deen_app_bar.dart';
import '../../../shared/widgets/chrome/deen_chrome.dart';
import '../providers/social_providers.dart';

class FamilyCirclesScreen extends ConsumerStatefulWidget {
  const FamilyCirclesScreen({super.key});

  @override
  ConsumerState<FamilyCirclesScreen> createState() =>
      _FamilyCirclesScreenState();
}

class _FamilyCirclesScreenState extends ConsumerState<FamilyCirclesScreen> {
  final _createController = TextEditingController();
  final _joinController = TextEditingController();
  String? _createdInviteCode;
  String? _statusMessage;
  bool _isLoading = false;
  String? _selectedCircleId;

  @override
  void dispose() {
    _createController.dispose();
    _joinController.dispose();
    super.dispose();
  }

  Future<void> _createCircle() async {
    final name = _createController.text.trim();
    if (name.isEmpty) {
      setState(() => _statusMessage = 'Please enter a circle name');
      return;
    }
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    try {
      final service = ref.read(supabaseServiceProvider);
      // Ensure anonymous sign-in for guest-first
      if (service.currentUser == null) {
        await service.signInAnonymously();
      }
      final row = await service.createCircle(name);
      setState(() {
        _createdInviteCode = row['invite_code'] as String?;
        _selectedCircleId = row['id'] as String?;
        _statusMessage = 'Circle created';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Failed to create circle: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinCircle() async {
    final code = _joinController.text.trim();
    if (code.length != 6) {
      setState(() => _statusMessage = 'Invite code must be 6 characters');
      return;
    }
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    try {
      final service = ref.read(supabaseServiceProvider);
      if (service.currentUser == null) {
        await service.signInAnonymously();
      }
      await service.joinCircle(code);
      setState(() => _statusMessage = 'Joined circle $code');
    } catch (e) {
      setState(() => _statusMessage = 'Failed to join: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: const DeenAppBar(title: 'Family Circles'),
      body: DeenChromeListener(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.spaceMD,
            topContentPad(context),
            AppSpacing.spaceMD,
            100,
          ),
          children: [
            Text('Create a circle', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            TextField(
              controller: _createController,
              decoration: const InputDecoration(
                labelText: 'Circle name',
                border: OutlineInputBorder(),
                hintText: 'e.g. Family',
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCircle,
                child: Text(_isLoading ? 'Creating...' : 'Create Circle'),
              ),
            ),
            if (_createdInviteCode != null) ...[
              const SizedBox(height: AppSpacing.spaceSM),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceMD),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  border: Border.all(color: AppColors.gold),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite code',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          SelectableText(
                            _createdInviteCode!,
                            style: AppTypography.titleLarge.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _createdInviteCode!),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invite code copied')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spaceLG),
            Text('Join a circle', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            TextField(
              controller: _joinController,
              decoration: const InputDecoration(
                labelText: 'Invite code (6 chars)',
                border: OutlineInputBorder(),
              ),
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinCircle,
                child: const Text('Join Circle'),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(height: AppSpacing.spaceLG),
            Text('Leaderboard', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Per-member minutes, streaks, and hasanat. Private to your circle only.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            if (_selectedCircleId != null)
              _LeaderboardSection(circleId: _selectedCircleId!),
            const SizedBox(height: AppSpacing.spaceLG),
            Text(
              'Counts are encouragement only; true reward is with Allah.',
              style: AppTypography.labelSmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Leaderboard with Today/Week/All tabs, rank medals, streak + hasanat
/// columns, and a pinned YOU row. Missing backend tables (pre-push)
/// degrade to an empty state with a Sync CTA instead of an error.
class _LeaderboardSection extends ConsumerWidget {
  const _LeaderboardSection({required this.circleId});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final range = ref.watch(boardRangeProvider);
    final rowsAsync = switch (range) {
      BoardRange.today => ref.watch(todayLeaderboardProvider(circleId)),
      BoardRange.week => ref.watch(weeklyLeaderboardProvider(circleId)),
      BoardRange.all => ref.watch(allTimeLeaderboardProvider(circleId)),
    };
    final lastUpdatedAsync = ref.watch(
      lastLeaderboardUpdatedProvider(circleId),
    );
    final myId = ref.watch(currentUserProvider)?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Leaderboard range',
          child: SegmentedButton<BoardRange>(
            segments: const [
              ButtonSegment(value: BoardRange.today, label: Text('Today')),
              ButtonSegment(value: BoardRange.week, label: Text('Week')),
              ButtonSegment(value: BoardRange.all, label: Text('All')),
            ],
            selected: {range},
            onSelectionChanged: (s) =>
                ref.read(boardRangeProvider.notifier).state = s.first,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSM),
        rowsAsync.when(
          data: (rows) {
            if (rows.isEmpty) {
              return _SyncEmptyState(
                isDark: isDark,
                range: range,
                onRetry: () => ref.invalidate(
                  range == BoardRange.today
                      ? todayLeaderboardProvider(circleId)
                      : range == BoardRange.week
                      ? weeklyLeaderboardProvider(circleId)
                      : allTimeLeaderboardProvider(circleId),
                ),
              );
            }
            // Pinned YOU row renders last, highlighted.
            final mine = <Map<String, dynamic>>[];
            final others = <Map<String, dynamic>>[];
            for (final r in rows) {
              if (myId != null && r['user_id'] == myId) {
                mine.add(r);
              } else {
                others.add(r);
              }
            }
            var rank = 0;
            Widget rowWidget(Map<String, dynamic> row, {bool pinned = false}) {
              rank++;
              return _LeaderboardRow(
                rank: pinned ? null : rank,
                row: row,
                pinned: pinned,
                isDark: isDark,
              );
            }

            return Column(
              children: [
                for (final r in others) rowWidget(r),
                if (mine.isNotEmpty) ...[
                  const Divider(height: AppSpacing.spaceMD),
                  for (final r in mine) rowWidget(r, pinned: true),
                ],
                const SizedBox(height: AppSpacing.spaceXS),
                lastUpdatedAsync.when(
                  data: (text) => text == null
                      ? const SizedBox.shrink()
                      : Text(
                          text,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Error loading leaderboard: $e',
            style: AppTypography.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Empty state with Sync CTA for pre-push backends and quiet weeks.
class _SyncEmptyState extends StatelessWidget {
  const _SyncEmptyState({
    required this.isDark,
    required this.range,
    required this.onRetry,
  });

  final bool isDark;
  final BoardRange range;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final label = switch (range) {
      BoardRange.today => 'today',
      BoardRange.week => 'this week',
      BoardRange.all => 'yet',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            'No stats $label',
            style: AppTypography.titleSmall.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          Text(
            'Read Quran or tap Sync to refresh the board.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync'),
          ),
        ],
      ),
    );
  }
}

/// Rich row: medal or rank, avatar initial, name, streak, hasanat.
class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.row,
    required this.pinned,
    required this.isDark,
  });

  final int? rank;
  final Map<String, dynamic> row;
  final bool pinned;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final profiles = row['profiles'];
    final name = profiles is Map && profiles['display_name'] != null
        ? profiles['display_name'] as String
        : (row['user_id'] as String).substring(0, 6);
    final minutes = row['total_minutes'] as int? ?? 0;
    final streak = row['current_streak'] as int? ?? 0;
    final hasanat = row['total_hasanat'] as int? ?? 0;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final r = rank;

    Widget leading;
    if (pinned) {
      leading = Container(
        width: 32,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        child: Text(
          'YOU',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (r != null && r <= 3) {
      const medal = [Color(0xFFFFD54F), Color(0xFFB0BEC5), Color(0xFFCC8F5A)];
      leading = CircleAvatar(
        radius: 16,
        backgroundColor: medal[r - 1],
        child: Text(
          '$r',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else {
      leading = SizedBox(
        width: 32,
        child: Text(
          '${rank ?? '–'}',
          style: AppTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Semantics(
      label: pinned ? '$name, your row' : '$name, rank $rank',
      value: '$minutes minutes, $streak streak, $hasanat hasanat',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceXS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceSM,
          vertical: AppSpacing.spaceXS,
        ),
        decoration: BoxDecoration(
          color: pinned
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          border: pinned
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.spaceSM),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodyMedium),
                  Text(
                    'streak $streak • $hasanat hasanat',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$minutes min',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
