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

If any source changes its license, we update this file and re-verify checksums before the next release.