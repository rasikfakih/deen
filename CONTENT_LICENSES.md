# Content Licenses

## Code

- **App code:** [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)
- Reference: [quran/quran_android](https://github.com/quran/quran_android) (GPL-3.0). Any adapted code keeps GPL-3.0 and attribution.

## Religious Content and Data

Content licenses are **per source**. Data is stored exactly as imported and never rewritten by AI. All files under `assets/data/` are SHA-256 checksummed.

| Dataset | Typical License | Notes |
|---------|-----------------|-------|
| Quran Arabic Uthmani (tanzil / quran.com) | CC BY-ND or CC BY | Verify per-file header; some tanzil dumps are CC BY-ND |
| Translations (QuranEnc / Sahih International) | CC BY-NC-ND | Non-commercial, no derivatives |
| Quran metadata via fawazahmed0/quran-api (mirror of tanzil+quranenc) | CC BY-NC-ND | Bundled verbatim; see `DATA_SOURCES.md` for upstream URLs |
| Mushaf coordination / KSU data | CC BY | Attribution required |
| Mushaf page images (King Fahd Complex via quran.com-images) | Per-source (OFL for fonts; images with KFGQPC permission) | **Madani only in v1.** Qaloon, Naskh, Indo-Pak deferred (separate permissions/coordinate systems) |
| Audio (Mishary Rashid Alafasy, Abdul Basit Abdus-Samad, etc.) | Free distribution / per-reciter permission | Served from our own R2 + CDN, not hotlinked at runtime |

## Commitments

- **Non-commercial:** The project will never monetize content beyond covering infra via optional donations. Content that is NC-licensed stays NC.
- **Attribution:** Every source is attributed in `DATA_SOURCES.md`, `README.md`, and the in-app About and Credits screen.
- **No AI rewriting:** Religious content enters only via `scripts/fetch_quran_data.dart` and is verified by `scripts/verify_quran_integrity.dart`.

## Fonts

- UI fonts (Poppins, Tajawal/Cairo) and Mushaf fonts (Amiri Quran / KFGQPC Uthman Taha) are bundled with their OFL licenses in `assets/fonts/`. No runtime font downloads.

## Icons

- **Lucide Icons:** [ISC license](https://lucide.dev/license) — 31 commodity glyphs vendored into `assets/icons/` (ic_home, ic_quran, ic_settings, ic_search, ic_bookmark, ic_bookmark_filled, ic_share, ic_close, ic_back, ic_copy, ic_external, ic_play, ic_pause, ic_speed, ic_next, ic_prev, ic_location, ic_bell, ic_clock, ic_streak, ic_freeze, ic_target, ic_trophy, ic_family, ic_invite, ic_heart, ic_check, ic_chevron_right, ic_chevron_left, ic_moon, ic_sun). Stroke width normalized from 2.0 to the Deen spec 1.8 on ingestion; geometry otherwise verbatim upstream. Source: https://lucide.dev (one-time ingestion, no clone kept in repo).
- **Custom identity set:** 10 original Deen glyphs (ic_hasanat, ic_badge_star, ic_tasbih, ic_qibla, ic_fajr, ic_sunrise, ic_dhuhr, ic_asr, ic_maghrib, ic_isha) drawn to the same 24x24 / 1.8 / round-cap spec. Same license as app code unless elevated to founder-crafted artwork later.

If any source changes its license, we update this file and re-verify checksums before the next release.