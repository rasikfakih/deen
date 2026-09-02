import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../prayer/providers/prayer_providers.dart';
import '../providers/qibla_providers.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  // Haversine distance to Mecca (offline)
  double _distanceKm(double lat1, double lon1) {
    const meccaLat = 21.4225;
    const meccaLng = 39.8261;
    const r = 6371.0;
    final dLat = (meccaLat - lat1) * math.pi / 180;
    final dLng = (meccaLng - lon1) * math.pi / 180;
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(meccaLat * math.pi / 180) *
            math.pow(math.sin(dLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qiblaAsync = ref.watch(qiblaWithHeadingProvider);
    final locAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Qibla'), centerTitle: true),
      body: qiblaAsync.when(
        data: (data) {
          final bearing = data.bearing;
          final heading = data.heading;
          final bearingStr = '${bearing.toStringAsFixed(1)}° from North';

          // Distance
          String distanceStr = '';
          final loc = locAsync.valueOrNull;
          if (loc != null) {
            final km = _distanceKm(loc.latitude, loc.longitude);
            distanceStr = '${km.toStringAsFixed(0)} km to Mecca';
          }

          if (heading == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_off,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      'Calibrate compass',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Text(
                      'Calibrate compass by moving device in a figure 8',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      bearingStr,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (distanceStr.isNotEmpty)
                      Text(
                        distanceStr,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          final deltaDeg = (bearing - heading) % 360;
          final deltaRad = deltaDeg * math.pi / 180;
          final isAligned = deltaDeg < 10 || deltaDeg > 350;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            child: Column(
              children: [
                Text(
                  bearingStr,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                if (distanceStr.isNotEmpty)
                  Text(
                    distanceStr,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                const SizedBox(height: AppSpacing.spaceMD),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkOutlineVariant
                                  : AppColors.lightOutlineVariant,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? AppColors.shadowDark
                                    : AppColors.shadowLight,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: _DialPainter(isDark: isDark),
                          ),
                        ),
                        // North marker
                        Positioned(
                          top: 22,
                          child: Text(
                            'N',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: deltaRad,
                          child: Icon(
                            Icons.navigation,
                            size: 64,
                            color: AppColors.gold,
                            shadows: [
                              Shadow(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Qibla ${deltaDeg.toStringAsFixed(0)}° ${isAligned ? '- Aligned!' : ''}',
                  style: AppTypography.titleMedium.copyWith(
                    color: isAligned
                        ? AppColors.success
                        : (isDark
                              ? AppColors.darkOnSurface
                              : AppColors.textDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXS),
                Text(
                  isAligned ? 'Face the needle' : 'Rotate device',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXL),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Text('Compass unavailable', style: AppTypography.bodyMedium),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final tickPaint = Paint()
      ..color = isDark
          ? AppColors.darkOutlineVariant
          : AppColors.lightOutlineVariant
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var deg = 0; deg < 360; deg += 30) {
      final rad = deg * math.pi / 180;
      final isCardinal = deg % 90 == 0;
      final len = isCardinal ? 10.0 : 6.0;
      final p1 = Offset(
        center.dx + (radius - len) * math.cos(rad),
        center.dy + (radius - len) * math.sin(rad),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(rad),
        center.dy + radius * math.sin(rad),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
