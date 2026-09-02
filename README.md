# Deen

Created by Rasik Fakih - free, open-source Muslim habit app.

**The habit science of Quranly plus a complete Muslim toolkit -- free forever, offline-first, global.**

Deen is an open-source Flutter app for Android and iOS that helps Muslims build consistent daily habits: reading Quran, praying on time, remembering Allah through tasbih and duas, and staying connected with family through private encouragement circles.

> **Non-commercial commitment:** Deen will never have ads, paywalls, or data selling. Optional Sadaqah Jariyah donations may cover infrastructure costs only. The project is built to survive forever at near-zero cost.

## Principles

1. Sacred content integrity above everything
2. Free for every person on earth, forever
3. Privacy by default
4. Offline-first and very fast
5. Premium, playful, respectful UX
6. Open source and community-aligned
7. Near-zero infrastructure cost

## Features (v1)

- Onboarding with daily goal (minimum 1 ayah), location/method choice, notifications opt-in
- Home dashboard: greeting, next prayer countdown, daily goal ring, streaks, Hasanat ticker
- Quran reader: Mushaf page-image (Madani) and text mode (Uthmani + translation), bookmarks, offline search
- Audio player with CDN streaming and offline cache
- Prayer times computed on-device (adhan), with notifications
- Qibla compass with guidance
- Tasbih counter with haptics
- Gamification: streaks, freezes, levels, badges (counts are encouragement only; true reward is with Allah)
- Settings: dark mode, Elderly Mode, font sizes, export/delete my data
- About and Credits screen

## Tech Stack

- Flutter (stable), `flutter_riverpod`, `drift` (SQLite + FTS5), `go_router`, `dio`, `adhan`, `geolocator`, `flutter_local_notifications`

## Getting Started

```bash
flutter pub get
dart run scripts/fetch_quran_data.dart
dart run scripts/verify_quran_integrity.dart
flutter run
```

Quality gates (must pass before merge):

```bash
dart format .
flutter analyze
flutter test
dart run scripts/verify_quran_integrity.dart
```

## Data Sources and Attribution

Deen displays religious content exactly as imported from verified open sources. No AI generates or rewrites Quran text, translations, or tafsir. Every data file is checksummed (`assets/data/checksums.sha256`).

| Source | Content | License | Attribution |
|--------|---------|---------|-------------|
| [quran.com API & quran/quran.com API](https://api.quran.com) / [quran.com project](https://quran.com) | Quran metadata, verse segmentation | MIT / CC BY | "Quran text and translations provided by quran.com and tanzil.net." |
| [tanzil.net](https://tanzil.net) | Uthmani Arabic text (Uthman Taha) | CC BY-ND / per-file | "Uthmani text from tanzil.net." |
| [quranenc.com (QuranEnc)](https://quranenc.com) | Translations (Sahih International and future languages) | CC BY-NC-ND | "Translations via quranenc.com." |
| [King Saud University -- QuranComplex / quran-ksu](https://quran.ksu.edu.sa) | Mushaf coordination data | CC BY | "Data sourced from King Saud University." |
| [King Fahd Quran Printing Complex (KFGQPC)](https://qurancomplex.gov.sa) / [quran.com-images](https://github.com/quran/quran.com-images) | Mushaf Madani page images & Uthman Taha fonts | Per-source (OFL / proprietary with permission) | "Mushaf images based on King Fahd Complex fonts." |
| [fawazahmed0/quran-api](https://github.com/fawazahmed0/quran-api) (CDN mirror of tanzil + quranenc) | Build-time JSON dumps (Arabic + Sahih Intl) | CC BY-NC-ND | "Bundled via fawazahmed0/quran-api CDN." |
| Reciters (Mishary Rashid Alafasy, Abdul Basit Abdus-Samad, etc.) | Audio | Free distribution / per-reciter permission | "Audio by respective reciters for free distribution." |

Quran text and translations provided by quran.com and tanzil.net. Mushaf images based on King Fahd Complex fonts. See `DATA_SOURCES.md` and `CONTENT_LICENSES.md` for full URLs, licenses, and hosting (bundled vs CDN).

> We never hotlink volunteer servers at runtime. Build tooling downloads once; the app serves from our own Cloudflare R2 + CDN or bundled assets.

## Licensing

- **Code:** [GPL-3.0](LICENSE) -- same as [quran/quran_android](https://github.com/quran/quran_android). Adapted code keeps GPL-3.0 and attribution.
- **Content:** Per source, typically CC BY-NC-ND. See `CONTENT_LICENSES.md`.
- **Fonts:** Bundled with OFL licenses. No runtime font downloads.

## Contributing

See `CONTRIBUTING.md`. All code requires human review. Run `dart format`, `flutter analyze`, `flutter test`, and `dart run scripts/verify_quran_integrity.dart` before pushing.

## Privacy

Guest-first, no mandatory login, location on-device, analytics opt-in only, GDPR export/delete. See `PRIVACY_PRINCIPLES.md`.

## Credits

In-app About and Credits screen lists all sources above. Thank you to the open-source Quran community and every contributor.

## Founder

Rasik Fakih (Founder) -- final human reviewer for all religious content and releases.