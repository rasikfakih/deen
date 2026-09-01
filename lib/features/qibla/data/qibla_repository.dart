import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Qibla logic — pure math + sensor stream, offline.
///
/// Uses adhan Qibla for bearing (spherical math) and flutter_compass for
/// magnetic heading. Never crashes if sensor unavailable.
class QiblaRepository {
  /// Returns Qibla bearing in degrees from true North (0-360 clockwise).
  /// 0 = North, 90 = East, 180 = South, 270 = West.
  double getQiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final qibla = Qibla(Coordinates(latitude, longitude));
    var dir = qibla.direction;
    // Normalize 0-360
    dir = dir % 360;
    if (dir < 0) dir += 360;
    return dir;
  }

  /// Stream of device magnetic heading (degrees from North, 0-360).
  /// Emits null if sensor unavailable (emulator) — UI should handle.
  Stream<double?> getCompassHeading() {
    final events = FlutterCompass.events;
    if (events == null) {
      return Stream.value(null);
    }
    return events.map((e) => e.heading);
  }

  /// Convenience: bearing + heading combined for UI.
  /// Emits (bearing, heading) pairs; heading may be null.
  Stream<({double bearing, double? heading})> getQiblaWithHeading({
    required double latitude,
    required double longitude,
  }) {
    final bearing = getQiblaDirection(latitude: latitude, longitude: longitude);
    return getCompassHeading().map((h) => (bearing: bearing, heading: h));
  }
}
