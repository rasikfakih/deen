import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Family Circles'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
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
          Text('Weekly leaderboard', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Shows total minutes per member for the current week, ordered highest first. Private to your circle only.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          if (_selectedCircleId != null)
            Consumer(
              builder: (context, ref, _) {
                final leaderboardAsync = ref.watch(
                  weeklyLeaderboardProvider(_selectedCircleId!),
                );
                final lastUpdatedAsync = ref.watch(
                  lastLeaderboardUpdatedProvider(_selectedCircleId!),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leaderboardAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) {
                          return Text(
                            'No stats yet for this week',
                            style: AppTypography.bodySmall,
                          );
                        }
                        return Column(
                          children: rows.asMap().entries.map((e) {
                            final idx = e.key;
                            final row = e.value;
                            final name =
                                (row['profiles'] != null &&
                                    row['profiles']['display_name'] != null)
                                ? row['profiles']['display_name'] as String
                                : (row['user_id'] as String).substring(0, 6);
                            final minutes = row['total_minutes'] as int;
                            return ListTile(
                              leading: Text(
                                '${idx + 1}',
                                style: AppTypography.titleMedium,
                              ),
                              title: Text(
                                name,
                                style: AppTypography.bodyMedium,
                              ),
                              trailing: Text(
                                '$minutes min',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.goldDark,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text(
                        'Error loading leaderboard: $e',
                        style: AppTypography.bodySmall,
                      ),
                    ),
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
            ),
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
    );
  }
}
