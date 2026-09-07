// App-wide constants per DEEN Sections 7 + 10.
// Feature-agnostic values live here; feature-specific keys stay in
// lib/features/<feature>/constants. All gamification thresholds are defined
// once here so UI, repos, and tests agree.

abstract final class AppConstants {
  static const String appName = 'Deen';
  static const String packageName = 'com.rasikfakih.deen';

  // Gamification (DEEN 10) — encouragement counts only.
  static const int hasanatPerAyah = 10;
  static const int beastModeMinutes = 30;
  static const int beastModeMultiplier = 2;
  static const int streakFreezeCap = 3;
  static const int streakFreezeEveryDays = 7;
  static const int minDailyAyahs = 1;
  static const String hasanatDisclaimer =
      'Counts are encouragement only; true reward is with Allah.';

  // Audio CDN — our own R2 bucket, never volunteer hotlinks at runtime (DEEN 5).
  // Override with --dart-define=AUDIO_CDN_BASE_URL=https://cdn.example.com/audio
  static const String audioCdnBaseUrl = String.fromEnvironment(
    'AUDIO_CDN_BASE_URL',
    defaultValue: 'https://cdn.deen.rasikfakih.com/audio',
  );

  // Supabase — injected via --dart-define, empty means guest/offline mode.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Support — Stripe link is configured at release; empty hides the button.
  static const String stripeDonateUrl = String.fromEnvironment(
    'STRIPE_DONATE_URL',
    defaultValue: '',
  );
  static const String githubSponsorsUrl =
      'https://github.com/sponsors/rasikfakih';
}
