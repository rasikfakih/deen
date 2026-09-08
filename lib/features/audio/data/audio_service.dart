import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/app_constants.dart';

/// Supported reciters (v1). Directory names match the R2 bucket layout:
/// `<base>/<reciter>/<surahId>.mp3` (full-surah files, 128 kbps).
enum DeenReciter {
  alafasy('ar.alafasy'),
  abdulBasit('ar.abdulbasitmurattal');

  const DeenReciter(this.slug);
  final String slug;
}

/// Audio architecture - streaming via just_audio, served from our own R2 CDN.
///
/// Runtime data comes ONLY from our bucket or local offline cache (DEEN 5).
/// No volunteer hotlinks at runtime. Base URL is configured with
/// `--dart-define=AUDIO_CDN_BASE_URL=...`, see [AppConstants.audioCdnBaseUrl].
/// Uses a single [AudioPlayer] and exposes state streams.
/// No bundling of MP3s to avoid binary bloat; on-demand download packs only.
class AudioService {
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// Builds a CDN URL for a full-surah file, e.g.
  /// `https://cdn.deen.../audio/ar.alafasy/1.mp3`.
  static String audioUrl({
    required int surahId,
    DeenReciter reciter = DeenReciter.alafasy,
    String? baseUrlOverride,
  }) {
    final base = (baseUrlOverride ?? AppConstants.audioCdnBaseUrl).replaceAll(
      RegExp(r'/+$'),
      '',
    );
    return '$base/${reciter.slug}/$surahId.mp3';
  }

  /// Legacy sample URL, kept for widget tests / dev only.
  /// Do NOT use in production — use [audioUrl] (R2) instead.
  @Deprecated('Use AudioService.audioUrl (R2 CDN) instead')
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
    final local = await _localFileForUrl(url);
    if (await local.exists()) {
      await _player.setFilePath(local.path);
    } else {
      await _player.setUrl(url);
    }
    await _player.play();
  }

  /// Plays a surah from R2 (or offline cache when downloaded).
  Future<void> playSurah(
    int surahId, {
    DeenReciter reciter = DeenReciter.alafasy,
  }) => playUrl(audioUrl(surahId: surahId, reciter: reciter));

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

  /// Loops the current source (surah repeat for the reader). No new
  /// dependency: just_audio LoopMode.
  Future<void> setLoopOne() => _player.setLoopMode(LoopMode.one);

  Future<void> setLoopOff() => _player.setLoopMode(LoopMode.off);

  Future<void> stop() async {
    await _player.stop();
  }

  /// Downloads a surah file into the offline cache (no new dependency —
  /// plain HttpClient). Returns the cached file. Re-downloads only when
  /// missing, so download packs survive restarts.
  Future<File> downloadForOffline(
    int surahId, {
    DeenReciter reciter = DeenReciter.alafasy,
  }) async {
    final url = audioUrl(surahId: surahId, reciter: reciter);
    final file = await _localFileForUrl(url);
    if (await file.exists()) return file;
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException(
          'Audio download failed: HTTP ${response.statusCode} for $url',
        );
      }
      await file.parent.create(recursive: true);
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.close();
      return file;
    } finally {
      client.close();
    }
  }

  Future<bool> isCached(int surahId, {DeenReciter? reciter}) async {
    final url = audioUrl(
      surahId: surahId,
      reciter: reciter ?? DeenReciter.alafasy,
    );
    return (await _localFileForUrl(url)).exists();
  }

  Future<File> _localFileForUrl(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    // <docs>/audio/<reciter>/<surah>.mp3 mirrors the CDN layout.
    final uri = Uri.parse(url);
    final tail = uri.pathSegments.length >= 2
        ? uri.pathSegments.sublist(uri.pathSegments.length - 2).join('/')
        : p.basename(uri.path);
    return File(p.join(dir.path, 'audio', tail));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
