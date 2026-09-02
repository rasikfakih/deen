import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/database/deen_database.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../prayer/providers/prayer_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _step = 0;

  final TextEditingController _nameController = TextEditingController();
  bool _isTimeGoal = true;
  int _selectedGoal = 5;
  bool _locationRequested = false;
  String _locationStatus = '';
  String _notificationStatus = '';

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _next();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final db = ref.read(deenDatabaseProvider);
      await db
          .into(db.settingsCache)
          .insertOnConflictUpdate(
            SettingsCacheCompanion.insert(key: 'user_name', value: Value(name)),
          );
    }
  }

  Future<void> _saveGoal() async {
    final db = ref.read(deenDatabaseProvider);
    // Deactivate old goals
    await (db.update(db.userGoals)..where((t) => t.isActive.equals(true)))
        .write(const UserGoalsCompanion(isActive: Value(false)));
    final minutes = _isTimeGoal ? _selectedGoal.clamp(1, 1440) : 15;
    final ayahs = !_isTimeGoal ? _selectedGoal.clamp(1, 1000) : 5;
    await db
        .into(db.userGoals)
        .insert(
          UserGoalsCompanion.insert(
            dailyTargetMinutes: Value(minutes),
            dailyTargetAyahs: Value(ayahs),
            isActive: const Value(true),
          ),
        );
  }

  Future<void> _requestLocation() async {
    setState(() => _locationRequested = true);
    try {
      final service = ref.read(locationServiceProvider);
      final loc = await service.getCurrentLocation();
      final isMecca = loc.latitude == 21.3891 && loc.longitude == 39.8579;
      setState(() {
        _locationStatus = isMecca
            ? 'Using Mecca as default. You can change later in Settings.'
            : 'Location enabled: ${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}';
      });
    } catch (_) {
      setState(
        () => _locationStatus =
            'Using Mecca as default. You can change later in Settings.',
      );
    }
  }

  Future<void> _requestNotifications() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      setState(
        () => _notificationStatus =
            'Notifications enabled. You will receive daily reminders.',
      );
    } else if (status.isPermanentlyDenied) {
      setState(
        () => _notificationStatus =
            'Notifications blocked. You can enable in app settings.',
      );
    } else {
      setState(
        () => _notificationStatus =
            'Notifications skipped. You can enable later in Settings.',
      );
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _finish() async {
    final db = ref.read(deenDatabaseProvider);
    await db
        .into(db.settingsCache)
        .insertOnConflictUpdate(
          SettingsCacheCompanion.insert(
            key: 'has_completed_onboarding',
            value: const Value('true'),
          ),
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / 4,
              backgroundColor: AppColors.creamDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 4,
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(context),
                  _buildGoalStep(context),
                  _buildLocationStep(context),
                  _buildNotificationStep(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMD),
              child: Row(
                children: [
                  Text(
                    '${_step + 1} / 4',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (_step == 0 || _step == 3)
                    TextButton(onPressed: _skip, child: const Text('Skip')),
                  const SizedBox(width: AppSpacing.spaceSM),
                  ElevatedButton(
                    onPressed: () async {
                      if (_step == 0) {
                        await _saveName();
                        _next();
                      } else if (_step == 1) {
                        await _saveGoal();
                        _next();
                      } else if (_step == 2) {
                        _next();
                      } else if (_step == 3) {
                        await _finish();
                      }
                    },
                    child: Text(_step == 3 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Deen',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Your companion for daily Quran, prayer, and remembrance. Let us personalize your experience.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          Text('What should we call you?', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.spaceSM),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter your name (optional)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'You can change this later in Settings.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your daily goal',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Choose a time or ayah goal. Minimum is 1. You can change this anytime.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Time'),
                icon: Icon(Icons.timer_outlined),
              ),
              ButtonSegment(
                value: false,
                label: Text('Ayahs'),
                icon: Icon(Icons.menu_book_outlined),
              ),
            ],
            selected: {_isTimeGoal},
            onSelectionChanged: (s) => setState(() {
              _isTimeGoal = s.first;
              _selectedGoal = _isTimeGoal ? 5 : 5;
            }),
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          Wrap(
            spacing: AppSpacing.spaceSM,
            children: (_isTimeGoal ? [5, 10, 15] : [5, 10, 20]).map((v) {
              final selected = _selectedGoal == v;
              return ChoiceChip(
                label: Text(_isTimeGoal ? '$v min' : '$v ayahs'),
                selected: selected,
                selectedColor: AppColors.gold,
                labelStyle: AppTypography.labelMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textDark,
                ),
                onSelected: (_) => setState(() => _selectedGoal = v),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Selected: $_selectedGoal ${_isTimeGoal ? 'minutes' : 'ayahs'} per day',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable location',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'We use your location only on your device to calculate accurate prayer times and Qibla direction. Your location is never sold and only synced if you enable sync.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestLocation,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Use my location'),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _next,
              child: const Text('Use Default (Mecca)'),
            ),
          ),
          if (_locationStatus.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceMD),
            Text(
              _locationStatus,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (_locationRequested && _locationStatus.contains('Mecca'))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.spaceSM),
              child: Text(
                'Tip: You can update location later in Settings.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay consistent',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Allow daily reading reminders and prayer time notifications. You can turn these off anytime in Settings.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestNotifications,
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Allow notifications'),
            ),
          ),
          if (_notificationStatus.contains('blocked')) ...[
            const SizedBox(height: AppSpacing.spaceSM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openSettings,
                child: const Text('Open App Settings'),
              ),
            ),
          ],
          if (_notificationStatus.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceMD),
            Text(
              _notificationStatus,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
