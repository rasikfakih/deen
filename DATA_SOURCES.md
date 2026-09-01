# Data Sources

Every dataset below is downloaded **once at build time** via `dart run scripts/fetch_quran_data.dart` and verified with `dart run scripts/verify_quran_integrity.dart` (`assets/data/checksums.sha256`). The app never hotlinks volunteer servers at runtime; it reads from bundled `assets/data/` or our own Cloudflare R2 + CDN.

## Quran Text & Translations (v1)

### 1. Arabic Uthmani Text

- **Source URL (primary CDN):** `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/ara-quranuthmanihaf.json` (mirror of tanzil)
- **Source URL (fallback):** `https://raw.githubusercontent.com/fawazahmed0/quran-api/1/editions/ara-quranuthmanihaf.json` and `https://tanzil.net/pub/quran/quran-uthmani.txt`
- **Upstream origin:** [tanzil.net](https://tanzil.net) / [quran.com](https://quran.com) verified Uthmani (Uthman Taha) data
- **License:** CC BY-ND (tanzil per-file header); see also `CONTENT_LICENSES.md`
- **Attribution text:** "Quran text and translations provided by quran.com and tanzil.net. Arabic Uthmani text via tanzil.net / quran.com."
- **Hosting:** **Bundled** as `assets/data/raw/quran_ar.json` (verbatim upstream). Committed for offline-first reproducible builds.
- **Verification:** SHA-256 in `assets/data/checksums.sha256`; integrity script fails build on mismatch.

### 2. English Translation -- Sahih International

- **Source URL (primary CDN):** `https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/eng-sahihinternational.json`
- **Source URL (fallback):** `https://raw.githubusercontent.com/fawazahmed0/quran-api/1/editions/eng-sahihinternational.json` and `https://quranenc.com/en/browse/english_saheeh`
- **Upstream origin:** [quranenc.com](https://quranenc.com) (QuranEnc), Sahih International
- **License:** CC BY-NC-ND
- **Attribution text:** "English Sahih International translation via quranenc.com (QuranEnc) mirrored by fawazahmed0/quran-api."
- **Hosting:** **Bundled** as `assets/data/raw/quran_en.json` (verbatim upstream).
- **Verification:** SHA-256 in `assets/data/checksums.sha256`.

### Architecture note

v1 bundles only Arabic + English Sahih Intl. The pipeline is designed to support many languages later via the same `fawazahmed0/quran-api` edition pattern (e.g. `fra-...`, `urd-...`). Normalization into the internal Drift schema happens in a future DB-seeding task; this task preserves upstream structure verbatim per CTO decision.

## Mushaf Page Images (Madani only in v1)

- **Source URL:** `https://github.com/quran/quran.com-images` (King Fahd Quran Printing Complex fonts)
- **License:** Per-source (fonts OFL; images with KFGQPC permission)
- **Attribution text:** "Mushaf images based on King Fahd Quran Printing Complex fonts."
- **Hosting:** **CDN (Cloudflare R2)** -- on-demand download packs, never bundled in base APK (keeps APK < 80 MB). Qaloon, Naskh, Indo-Pak deferred to later versions.

## Audio (v1: Mishary Rashid Alafasy, Abdul Basit Abdus-Samad)

- **Source:** Free-distribution recitations (each reciter with permission)
- **License:** Free distribution / per-reciter permission
- **Attribution text:** "Audio by respective reciters for free distribution."
- **Hosting:** **CDN (Cloudflare R2)** -- streamed with optional offline cache. Downloaded once, served from our bucket.

## Other datasets

- **Mushaf coordination / KSU:** `https://quran.ksu.edu.sa` -- CC BY -- bundled or CDN per feature.
- **Prayer times:** Computed on-device with `adhan` (no dataset download; online APIs only as optional fallback).
- **Fonts:** OFL -- bundled in `assets/fonts/` (no runtime downloads).

## Credits

All sources above are credited in `README.md` and on the in-app About and Credits screen.