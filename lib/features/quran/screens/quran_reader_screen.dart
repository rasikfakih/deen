import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/screen_insets.dart';
import '../../../shared/widgets/chrome/deen_app_bar.dart';
import '../../../shared/widgets/chrome/deen_chrome.dart';
import '../../../shared/widgets/icons/deen_symbol_effects.dart';
import '../../audio/providers/audio_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../data/quran_repository.dart';
import '../providers/quran_providers.dart';

/// Beautiful, distraction-free text-mode Quran reader.
///
/// Sacred layer per DEEN 8: calm, spacious, minimal motion, zero clutter.
/// Shows Arabic Uthmani (Tajawal, Amiri/KFGQPC when provisioned) + English Sahih Intl
/// below, grouped by Surah. Verbatim data only via QuranRepository.
/// Bookmark via AppBar, last-read auto-saves, hasanat via gamification timer.
class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Single source of truth for the reading session (addendum E): the set
  /// of tapped ayah keys plus the open timestamp. Scroll logging was removed
  /// so awards can never double-count. Only I'm Done commits, once.
  final Set<String> _sessionAyahKeys = {};
  late DateTime _sessionStart;
  QuranAyah? _currentAyah;
  bool _hasRestoredLastRead = false;
  bool _loopEnabled = false;
  bool _justCommitted = false;
  bool _committing = false;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // LastRead tracking could be precise with itemPositionsListener;
    // for MVP we update on scroll end via currentAyah already set in builder.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Registers a read ayah in the session ledger (tap or jump target).
  void _registerAyah(QuranAyah ayah) {
    _sessionAyahKeys.add(ayah.key);
    _currentAyah = ayah;
  }

  /// I'm Done: the ONLY commit point. Minutes from elapsed open time,
  /// ayahs from unique tapped keys. Preview rate (Next button) always
  /// equals this base rate: AppConstants.hasanatPerAyah per ayah.
  Future<void> _commitSession() async {
    if (_committing) return;
    if (_sessionAyahKeys.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tap an ayah you read first, then press Done.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    setState(() => _committing = true);
    try {
      final repo = ref.read(gamificationRepositoryProvider);
      final elapsed = DateTime.now().difference(_sessionStart);
      // Count encouragement only; true reward is with Allah.
      await repo.logReadingSession(
        minutes: elapsed.inMinutes.clamp(1, 24 * 60),
        ayahs: _sessionAyahKeys.length.clamp(1, 6236),
      );
      await repo.checkAndUpdateStreak();
      _sessionAyahKeys.clear();
      _sessionStart = DateTime.now();
      if (mounted) {
        setState(() => _justCommitted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session saved — mashaAllah, keep going.'),
            duration: Duration(seconds: 2),
          ),
        );
        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _justCommitted = false);
        });
      }
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  /// Surah-level playback (honest R1 wiring; ayah-level needs timestamped
  /// R2 assets). Streams this surah's file from our CDN or offline cache.
  Future<void> _playSurah(int surahId) async {
    try {
      await ref.read(audioServiceProvider).playSurah(surahId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing Surah $surahId'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio unavailable offline: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleRepeat() async {
    final service = ref.read(audioServiceProvider);
    if (_loopEnabled) {
      await service.setLoopOff();
    } else {
      await service.setLoopOne();
    }
    if (mounted) setState(() => _loopEnabled = !_loopEnabled);
  }

  /// Clipboard share: verbatim ayah + translation + reference (addendum E).
  Future<void> _shareAyah(BuildContext context, QuranAyah ayah) async {
    final text =
        '${ayah.arabic}\n${ayah.english}\nSurah ${ayah.surahId} • Ayah ${ayah.ayahId}';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayah copied'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// First ayah index per surah, computed from verified data at runtime
  /// (no metadata file needed; counts are structural, not content).
  static Map<int, int> _surahStarts(List<QuranAyah> ayahs) {
    final starts = <int, int>{};
    for (var i = 0; i < ayahs.length; i++) {
      starts.putIfAbsent(ayahs[i].surahId, () => i);
    }
    return starts;
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    final offset = (index * 140).toDouble().clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _jumpToSurah(List<QuranAyah> ayahs, int surahId) async {
    final idx = _surahStarts(ayahs)[surahId];
    if (idx == null) return;
    final ayah = ayahs[idx];
    _registerAyah(ayah);
    await _updateLastRead(ayah);
    if (mounted) {
      setState(() {});
      _scrollToIndex(idx);
    }
  }

  /// Previous/next surah jumps. Jump targets register in the session
  /// ledger (single source); Next previews the per-ayah base rate.
  Future<void> _jumpSurah(List<QuranAyah> ayahs, int dir) async {
    final starts = _surahStarts(ayahs);
    final ordered = starts.keys.toList()..sort();
    final currentSurah = _currentAyah?.surahId ?? ordered.first;
    var pos = ordered.indexOf(currentSurah);
    pos = (pos + dir).clamp(0, ordered.length - 1);
    await _jumpToSurah(ayahs, ordered[pos]);
  }

  Future<void> _toggleBookmark(QuranAyah ayah) async {
    final toggle = ref.read(toggleBookmarkProvider);
    await toggle(surahId: ayah.surahId, ayahId: ayah.ayahId);
  }

  Future<void> _updateLastRead(QuranAyah ayah) async {
    final updater = ref.read(updateLastReadProvider);
    await updater(surahId: ayah.surahId, ayahId: ayah.ayahId);
    // Track recent surahs for Home quick chips (IDs only, R1.5 adds names).
    final pushRecent = ref.read(pushRecentSurahProvider);
    await pushRecent(ayah.surahId);
  }

  @override
  Widget build(BuildContext context) {
    final quranAsync = ref.watch(quranDataProvider);
    final bookmarkedKeys = ref.watch(bookmarkedKeysProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.mushafNight : AppColors.readerCanvas,
      appBar: DeenAppBar(
        title: 'Al-Quran - Text Mode',
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final current = _currentAyah;
              // Surah-level state: filled gold iff the current surah has
              // ANY bookmark (DEEN v6 reader spec).
              final surahHas =
                  current != null &&
                  bookmarkedKeys.any(
                    (k) => k.startsWith('${current.surahId}:'),
                  );
              final isBookmarked =
                  current != null && bookmarkedKeys.contains(current.key);
              return IconButton(
                tooltip: surahHas ? 'Surah bookmarked' : 'Bookmark ayah',
                icon: DeenAnimatedIcon(
                  effect: DeenSymbolEffect.bounce,
                  replayKey: isBookmarked,
                  child: Icon(
                    surahHas ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
                color: surahHas ? AppColors.gold : null,
                onPressed: current == null
                    ? null
                    : () async {
                        await _toggleBookmark(current);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBookmarked
                                    ? 'Bookmark removed'
                                    : 'Ayah ${current.surahId}:${current.ayahId} bookmarked',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
              );
            },
          ),
          const SizedBox(width: AppSpacing.spaceXS),
        ],
      ),
      body: quranAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                Text(
                  'Unable to load Quran - offline data missing',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spaceXS),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (ayahs) {
          if (ayahs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                      semanticLabel: 'Empty Quran data',
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      'Quran text is not available yet',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Text(
                      'Your offline Quran data seems to be missing. Reinstalling the app restores it — your progress stays on this device.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          // Restore last read once.
          ref.listen(lastReadProvider, (prev, next) {
            if (_hasRestoredLastRead) return;
            final last = next.valueOrNull;
            if (last == null) return;
            final idx = ayahs.indexWhere(
              (a) => a.surahId == last.surahId && a.ayahId == last.ayahId,
            );
            if (idx >= 0 && _scrollController.hasClients) {
              _hasRestoredLastRead = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    (idx * 140).toDouble().clamp(
                      0,
                      _scrollController.position.maxScrollExtent,
                    ),
                  );
                }
              });
            }
          });
          // Initialize current ayah to first.
          if (_currentAyah == null && ayahs.isNotEmpty) {
            _currentAyah = ayahs.first;
          }

          return DeenChromeListener(
            child: Column(
              children: [
                // Top-leak guard: first content clears the glass app bar.
                SizedBox(height: topContentPad(context)),
                // Surah selector + position progress (numeric until R1.5).
                _SurahSelectorRow(
                  ayahs: ayahs,
                  current: _currentAyah,
                  onSelect: _jumpToSurah,
                ),
                _ReaderProgressBar(ayahs: ayahs, current: _currentAyah),
                // Microcopy per DEEN 3 / 10
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMD,
                    vertical: AppSpacing.spaceXS,
                  ),
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  child: Text(
                    'Counts are encouragement only; true reward is with Allah.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    // First ayah card sits 12dp below the header; no spacer.
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: ayahs.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      final ayah = ayahs[index];
                      final prevSurah = index > 0
                          ? ayahs[index - 1].surahId
                          : null;
                      final isSurahHeader = prevSurah != ayah.surahId;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isSurahHeader) _SurahBand(surahId: ayah.surahId),
                          _AyahCard(
                            ayah: ayah,
                            isBookmarked: bookmarkedKeys.contains(ayah.key),
                            loopEnabled: _loopEnabled,
                            onTap: () {
                              _registerAyah(ayah);
                              _updateLastRead(ayah);
                              setState(() {});
                            },
                            onBookmarkToggle: () => _toggleBookmark(ayah),
                            onPlaySurah: () => _playSurah(ayah.surahId),
                            onToggleRepeat: _toggleRepeat,
                            onShare: () => _shareAyah(context, ayah),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _ReaderActionBar(
                  onPrevious: () => _jumpSurah(ayahs, -1),
                  onNext: () => _jumpSurah(ayahs, 1),
                  onDone: _commitSession,
                  committing: _committing,
                  justCommitted: _justCommitted,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.isBookmarked,
    required this.loopEnabled,
    required this.onTap,
    required this.onBookmarkToggle,
    required this.onPlaySurah,
    required this.onToggleRepeat,
    required this.onShare,
  });

  final QuranAyah ayah;
  final bool isBookmarked;
  final bool loopEnabled;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onPlaySurah;
  final VoidCallback onToggleRepeat;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // White card (darkSurface in dark mode), radius 20, DeenCard shadow.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSM,
                    vertical: AppSpacing.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkOutline
                          : AppColors.lightOutline,
                    ),
                  ),
                  child: Text(
                    '${ayah.surahId}:${ayah.ayahId}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Spacer(),
                _CardAction(
                  tooltip: 'Play Surah',
                  icon: Icons.play_arrow,
                  onTap: onPlaySurah,
                ),
                _CardAction(
                  tooltip: loopEnabled ? 'Stop repeat' : 'Repeat surah',
                  icon: Icons.repeat,
                  active: loopEnabled,
                  onTap: onToggleRepeat,
                ),
                _CardAction(
                  tooltip: 'Copy ayah',
                  icon: Icons.share_outlined,
                  onTap: onShare,
                ),
                InkWell(
                  onTap: onBookmarkToggle,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spaceXS),
                    child: DeenAnimatedIcon(
                      effect: DeenSymbolEffect.bounce,
                      replayKey: isBookmarked,
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: AppSpacing.iconSM,
                        color: isBookmarked
                            ? AppColors.gold
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            // Arabic - RTL, Tajawal via app_typography
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.arabic,
                style: AppTypography.arabicStyle(
                  fontSize: 24,
                  height: 1.8,
                  color: isDark ? AppColors.darkOnSurface : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            // Translation lives INSIDE the white card (v6 composition).
            Text(
              ayah.english,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFFC2B8A8) : AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed night surah band with gold title (numeric until R1.5).
class _SurahBand extends StatelessWidget {
  const _SurahBand({required this.surahId});

  final int surahId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Surah $surahId',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceSM,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF191410), Color(0xFF2A2018)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Text(
          'Surah $surahId',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXS),
        child: Icon(
          icon,
          size: AppSpacing.iconSM,
          color: active ? AppColors.gold : AppColors.textMuted,
          semanticLabel: tooltip,
        ),
      ),
    );
  }
}

/// Surah selector: numeric card opening a 1-114 picker with per-surah
/// ayah counts computed at runtime from verified data (no metadata file).
class _SurahSelectorRow extends StatelessWidget {
  const _SurahSelectorRow({
    required this.ayahs,
    required this.current,
    required this.onSelect,
  });

  final List<QuranAyah> ayahs;
  final QuranAyah? current;
  final Future<void> Function(List<QuranAyah>, int) onSelect;

  Map<int, int> _counts() {
    final counts = <int, int>{};
    for (final a in ayahs) {
      counts[a.surahId] = (counts[a.surahId] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _openPicker(BuildContext context) async {
    final counts = _counts();
    final ids = counts.keys.toList()..sort();
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          itemCount: ids.length,
          itemBuilder: (_, i) => ListTile(
            title: Text('Surah ${ids[i]}'),
            trailing: Text(
              '${counts[ids[i]]} ayahs',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            onTap: () => Navigator.of(ctx).pop(ids[i]),
          ),
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await onSelect(ayahs, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceMD,
        AppSpacing.spaceSM,
        AppSpacing.spaceMD,
        AppSpacing.spaceXS,
      ),
      child: Semantics(
        button: true,
        label: 'Select surah',
        value: current == null ? 'none' : 'Surah ${current!.surahId}',
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          onTap: () => _openPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMD,
              vertical: AppSpacing.spaceSM,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              border: Border.all(
                color: isDark
                    ? AppColors.darkOutlineVariant
                    : AppColors.lightOutlineVariant,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: AppColors.goldDark,
                ),
                const SizedBox(width: AppSpacing.spaceSM),
                Expanded(
                  child: Text(
                    current == null
                        ? 'Select surah'
                        : 'Surah ${current!.surahId}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin position progress: "ayah X of Y" plus percent (sacred, static).
class _ReaderProgressBar extends StatelessWidget {
  const _ReaderProgressBar({required this.ayahs, required this.current});

  final List<QuranAyah> ayahs;
  final QuranAyah? current;

  @override
  Widget build(BuildContext context) {
    final idx = current == null
        ? 0
        : ayahs.indexWhere(
            (a) => a.surahId == current!.surahId && a.ayahId == current!.ayahId,
          );
    final pos = idx < 0 ? 0 : idx + 1;
    final total = ayahs.length;
    final progress = total == 0 ? 0.0 : (pos / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    return Semantics(
      label: 'Reading position',
      value: 'ayah $pos of $total, $percent percent',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ayah $pos of $total',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom action bar: Previous, I'm Done, Next with hasanat preview.
/// The preview equals the commit base rate: AppConstants.hasanatPerAyah.
/// Spark appears on the bar after commit, never over ayah text.
class _ReaderActionBar extends StatelessWidget {
  const _ReaderActionBar({
    required this.onPrevious,
    required this.onNext,
    required this.onDone,
    required this.committing,
    required this.justCommitted,
  });

  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final Future<void> Function() onDone;
  final bool committing;
  final bool justCommitted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceMD,
        AppSpacing.spaceSM,
        AppSpacing.spaceMD,
        100,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mushafNight : AppColors.parchment,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkOutlineVariant
                : AppColors.lightOutlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: 'Previous surah',
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: OutlinedButton.icon(
                  onPressed: () => onPrevious(),
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text(
                    'Prev',
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            flex: 2,
            child: Semantics(
              button: true,
              label: "I'm done, save reading session",
              child: ElevatedButton.icon(
                onPressed: committing ? null : () => onDone(),
                icon: justCommitted
                    ? const Icon(Icons.auto_awesome, size: 18)
                    : const Icon(Icons.check, size: 18),
                label: Text(committing ? 'Saving…' : "I'm Done"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: Semantics(
              button: true,
              label:
                  'Next surah, plus ${AppConstants.hasanatPerAyah} hasanat per ayah',
              child: OutlinedButton(
                onPressed: () => onNext(),
                child: Text('Next +${AppConstants.hasanatPerAyah}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
