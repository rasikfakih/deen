import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

final audioPlayerStateProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.playerStateStream;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.positionStream;
});

final audioDurationProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.durationStream;
});

final audioIsPlayingProvider = Provider<bool>((ref) {
  final async = ref.watch(audioPlayerStateProvider);
  return async.valueOrNull?.playing ?? false;
});
