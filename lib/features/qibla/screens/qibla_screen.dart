import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_canvas.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/deen_card.dart';
import '../../../shared/widgets/glass/deen_glass_app_bar.dart';
import '../../../shared/widgets/icons/deen_symbol_effects.dart';
import '../../prayer/data/location_service.dart';
import '../../prayer/providers/prayer_providers.dart';
import '../providers/qibla_providers.dart';

/// Design v5 Qibla: theme canvas with radial gold glow behind a large dial
/// (15° ticks + cardinal letters), gradient needle that settles on >5°
/// heading changes, bearing above and distance below the dial, hold-flat
/// hint, calibration empty state. Static in Elderly Mode.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  /// Last settled 5° bucket; needle re-settles only across buckets.
  int? _lastBucket;

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qiblaAsync = ref.watch(qiblaWithHeadingProvider);
    final locAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      // Non-scrolling screen: no extendBodyBehindAppBar (top-leak rule).
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: const DeenGlassAppBar(title: 'Qibla'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: CanvasGradient.forBrightness(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          qiblaAsync.when(
            data: (data) =>
                _buildDial(context, ref, isDark, data, locAsync.valueOrNull),
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(
              child: Text(
                'Compass unavailable',
                style: AppTypography.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDial(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ({double bearing, double? heading}) data,
    AppLocation? loc,
  ) {
    final bearing = data.bearing;
    final heading = data.heading;
    final bearingStr = '${bearing.toStringAsFixed(1)}° from North';

    String distanceStr = '';
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
                semanticLabel: 'Compass unavailable',
              ),
              const SizedBox(height: AppSpacing.spaceMD),
              Text(
                'Calibrate compass',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.textDark,
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
    final bucket = deltaDeg ~/ 5;
    if (_lastBucket != bucket) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _lastBucket = bucket);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dialSize = (constraints.maxWidth - AppSpacing.spaceMD * 2).clamp(
          200.0,
          320.0,
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spaceMD,
            AppSpacing.spaceSM,
            AppSpacing.spaceMD,
            100,
          ),
          child: Column(
            children: [
              Semantics(
                label: 'Qibla bearing',
                value: bearingStr,
                child: Text(
                  bearingStr,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSM),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const DeenGlowSpot(diameter: 300),
                      Semantics(
                        label: 'Qibla dial',
                        value: isAligned
                            ? 'Aligned with Mecca'
                            : '${deltaDeg.toStringAsFixed(0)} degrees off',
                        child: Container(
                          width: dialSize,
                          height: dialSize,
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
                            child: Stack(
                              children: [
                                for (final entry in const [
                                  ('N', Alignment.topCenter, true),
                                  ('E', Alignment.centerRight, false),
                                  ('S', Alignment.bottomCenter, false),
                                  ('W', Alignment.centerLeft, false),
                                ])
                                  Align(
                                    alignment: entry.$2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Text(
                                        entry.$1,
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                              color: entry.$3
                                                  ? AppColors.goldDark
                                                  : AppColors.textMuted,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      DeenAnimatedIcon(
                        effect: DeenSymbolEffect.settle,
                        replayKey: _lastBucket ?? bucket,
                        child: Transform.rotate(
                          angle: deltaRad,
                          child: CustomPaint(
                            size: Size(dialSize * 0.32, dialSize * 0.32),
                            painter: const _NeedlePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (distanceStr.isNotEmpty)
                Text(
                  distanceStr,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              const SizedBox(height: AppSpacing.spaceXS),
              Text(
                'Qibla ${deltaDeg.toStringAsFixed(0)}° ${isAligned ? '- Aligned!' : ''}',
                style: AppTypography.titleMedium.copyWith(
                  color: isAligned
                      ? AppColors.success
                      : (isDark ? AppColors.darkOnSurface : AppColors.textDark),
                ),
              ),
              Text(
                isAligned ? 'Face the needle' : 'Rotate device',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSM),
              DeenCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMD,
                  vertical: AppSpacing.spaceSM,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.screen_rotation_outlined,
                      size: 20,
                      color: AppColors.goldDark,
                    ),
                    const SizedBox(width: AppSpacing.spaceSM),
                    Expanded(
                      child: Text(
                        'Hold your phone flat for the most accurate reading.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Gradient compass needle pointing up (rotated by the parent).
class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = AppGradients.goldFlow.createShader(rect)
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w / 2, h * 0.52)
      ..lineTo(w * 0.32, h * 0.62)
      ..close();
    canvas.drawPath(path, paint);
    final tail = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.fill;
    final tailPath = Path()
      ..moveTo(w / 2, h)
      ..lineTo(w * 0.62, h * 0.66)
      ..lineTo(w / 2, h * 0.56)
      ..lineTo(w * 0.38, h * 0.66)
      ..close();
    canvas.drawPath(tailPath, tail);
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter oldDelegate) => false;
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
    final cardinalPaint = Paint()
      ..color = AppColors.goldDark
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var deg = 0; deg < 360; deg += 15) {
      final rad = deg * math.pi / 180;
      final isCardinal = deg % 90 == 0;
      final len = isCardinal ? 12.0 : 6.0;
      final p1 = Offset(
        center.dx + (radius - len) * math.cos(rad),
        center.dy + (radius - len) * math.sin(rad),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(rad),
        center.dy + radius * math.sin(rad),
      );
      canvas.drawLine(p1, p2, isCardinal ? cardinalPaint : tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
