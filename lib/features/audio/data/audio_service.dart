import 'package:just_audio/just_audio.dart';

/// Audio architecture - streaming via just_audio, R2-ready.
///
/// Uses a single [AudioPlayer] and exposes state streams.
/// Placeholder URL will be swapped to our Cloudflare R2 CDN later
/// per DATA_SOURCES.md. No bundling of MP3s to avoid binary bloat.
class AudioService {
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// Public domain Alafasy sample for architecture proof (128 kbps).
  /// Will be replaced by `https://cdn.<r2>.dev/audio/<reciter>/<surah>_<ayah>.mp3`
  static const String placeholderUrl =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3';

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get speedStream => _player.speedStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> playUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> playPlaceholder() => playUrl(placeholderUrl);

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
