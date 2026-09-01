import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prayer/providers/prayer_providers.dart';
import '../data/qibla_repository.dart';

final qiblaRepositoryProvider = Provider<QiblaRepository>(
  (ref) => QiblaRepository(),
);

/// Qibla bearing from current location (degrees from North).
final qiblaDirectionProvider = FutureProvider<double>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final repo = ref.watch(qiblaRepositoryProvider);
  return repo.getQiblaDirection(
    latitude: location.latitude,
    longitude: location.longitude,
  );
});

/// Device magnetic heading stream (nullable if sensor unavailable).
final compassHeadingProvider = StreamProvider<double?>((ref) {
  final repo = ref.watch(qiblaRepositoryProvider);
  return repo.getCompassHeading();
});

/// Combined stream: bearing + heading for UI needle.
/// Emits every heading update with current bearing.
final qiblaWithHeadingProvider =
    // ignore: deprecated_member_use
    StreamProvider<({double bearing, double? heading})>((ref) async* {
      final bearing = await ref.watch(qiblaDirectionProvider.future);
      // ignore: deprecated_member_use
      final compassStream = ref.watch(compassHeadingProvider.stream);
      await for (final heading in compassStream) {
        yield (bearing: bearing, heading: heading);
      }
    });
