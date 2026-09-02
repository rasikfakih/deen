# DEEN_AI_CONTEXT.md
# Master engineering and product context for the Deen app
# Maintained by: Rasik Fakih (Founder) and CTO
# Version: 1.1 - Rebranded to rasikfakih (fix/rebrand)

---

## 0. Instructions for the AI coding agent

1. Read this entire file before any task. If a chat instruction conflicts with this file, this file wins.
2. Work on exactly one task per session. Do not expand scope silently.
3. NEVER generate, rewrite, paraphrase, summarize, translate, or modify religious content: Quran Arabic text, translations, tafsir, hadith, duas, or religious rulings. Religious content enters the app ONLY via files in assets/data produced by scripts and verified by checksums.
4. NEVER add a new package dependency without listing it and justifying it in your output.
5. NEVER commit to main. Work on feature branches only.
6. Before finishing any task run: dart format . , flutter analyze , flutter test , and the data integrity script when data files are involved.
7. End every task with: changed file tree, commands run, decisions made, open questions.
8. If a requirement is ambiguous, state your assumption explicitly and choose the safest option.
9. Production quality only: null-safe, strongly typed, no dead code, no unexplained TODOs.
10. The app must never feel synthetic. Section 17 is law.

---

## 1. Project identity

- Product name: Deen (working title: Deen Muslim)
- Platforms: Android and iOS via Flutter
- Category: Islamic lifestyle and habit-building app
- Positioning: the habit science plus a complete Muslim toolkit; free forever, open source, offline-first, global
- Founder and product owner: Rasik Fakih (6 years technology experience, final human reviewer)
- Engineering loop: Developer implements -> CTO reviews architecture and PRs in chat -> Rasik tests on physical device -> merge
- Package placeholder: com.rasikfakih.deen
- Business model: none. No ads, no paywalls, no data selling. Optional Sadaqah Jariyah donation entry to cover infrastructure only.

---

## 2. Core principles, in priority order

1. Sacred content integrity above everything.
2. Free for every person on earth, forever.
3. Privacy by default.
4. Offline-first and very fast.
5. Premium, playful, respectful UX.
6. Open source and community-aligned.
7. Near-zero infrastructure cost so the project can survive forever.

---

## 3. Religious content safety (non-negotiable)

- AI may write code, tests, UI, tooling, and documentation ONLY.
- All Quran text, translations, tafsir, duas, and hadith come from verified open sources and are stored exactly as imported.
- Every data file has a SHA-256 checksum; builds fail if any checksum mismatches (scripts/verify_quran_integrity.dart).
- The app displays an About and Credits screen attributing all data sources.
- Any feature that could imply religious rulings (for example Dua Q&A) must use a curated, scholar-reviewed static dataset or links to trusted sources. Never automated answers.
- Gamification numbers (Hasanat counts) are motivational estimates. The UI must include the microcopy: "Counts are encouragement only; true reward is with Allah."

---

## 4. Legal and licensing

- App code license: GPL-3.0.
- Content licenses: per source, typically CC BY-NC-ND. Documented in CONTENT_LICENSES.md.
- Non-commercial commitment documented in README and in-app About.
- Reference project: quran/quran_android (GPL-3.0). Study it; if any of its code is adapted, keep GPL-3.0 and attribution.
- Respect the quran.com community: their servers are volunteer-funded. We never hotlink them at runtime.

---

## 5. Data sources and hosting

- Runtime data is served ONLY from our own Cloudflare R2 bucket plus CDN, or bundled assets. One-time downloads happen in build tooling, never at app runtime from volunteer servers.
- Arabic text: Uthmani, from tanzil / quran.com verified data.
- Translations v1: English, Sahih International. Architecture must support many languages later via fawazahmed0/quran-api datasets.
- Mushaf page images v1: Madani only, generated from quran.com-images (King Fahd Quran Printing Complex fonts). Qaloon, Naskh, and Indo-Pak are deferred to later versions because they require separate permissions or coordinate systems.
- Audio v1: Mishary Rashid Alafasy and Abdul Basit Abdus-Samad from free-distribution sources, downloaded once, served from our CDN, streamed with optional offline cache.
- Prayer times: computed on-device with the adhan Dart package. Online APIs only as optional fallback.
- Tooling: scripts/fetch_quran_data.sh downloads and stages data; assets/data/checksums.sha256 stores hashes; scripts/verify_quran_integrity.dart fails the build on any mismatch.

---

## 6. Technical stack

- Flutter, latest stable channel
- State management: flutter_riverpod
- Local database: drift (SQLite), FTS5 for offline search
- Routing: go_router with ShellRoute bottom navigation
- Networking: dio
- Animations: flutter_animate and lottie
- Location: geolocator
- Prayer math: adhan
- Notifications: flutter_local_notifications plus timezone data
- Compass: sensors-based compass package for Qibla
- Backend (optional accounts, sync, leaderboards): supabase_flutter
- Analytics (opt-in only): posthog_flutter or self-hosted PostHog
- Fonts: bundled locally as assets with OFL licenses. Do NOT rely on runtime font downloads. Poppins (Latin UI), Tajawal or Cairo (Arabic UI), Amiri Quran or KFGQPC Uthman Taha (Mushaf text mode)
- Build tooling: build_runner, drift_dev, freezed where justified

---

## 7. Architecture

Feature-first structure. Features must never import each other; they import only core and shared.

lib/core/theme
lib/core/router
lib/core/constants
lib/core/utils
lib/core/errors
lib/shared/widgets
lib/shared/database
lib/shared/services
lib/features/home
lib/features/quran
lib/features/prayer
lib/features/qibla
lib/features/tasbih
lib/features/gamification
lib/features/duas
lib/features/audio
lib/features/reminders
lib/features/social
lib/features/profile
lib/features/settings
assets/fonts
assets/animations
assets/images
assets/data
scripts
test

Rules:
- Heavy database work runs off the main isolate.
- Every feature exposes a riverpod provider API; UI stays declarative.
- Drift tables v1: UserGoals, DailyReads, Streaks, HasanatLedger, Bookmarks, Favorites, LastRead, TasbihCounters, SettingsCache, PrayerCache.

---

## 8. Design system

Palette:
- Gold primary: #FFB030
- Earth brown secondary: #874D14
- Cream background light: #F9F6F0
- Text dark: #1F1F1F
- Dark background: #121212
- Surfaces dark: #1E1B16 family, tuned for WCAG AA contrast

Typography:
- Latin UI: Poppins
- Arabic UI labels: Tajawal or Cairo
- Mushaf text mode: Amiri Quran or KFGQPC Uthman Taha

Rules:
- 4/8pt spacing scale, consistent radii scale, soft shadows.
- Glassmorphism only where it earns its place.
- Two emotional layers:
  - Playful layer: Home, progress, streaks, badges, family circles, reminders, goal completion. Rich motion, Lottie celebrations, haptics.
  - Sacred layer: Quran reading, duas, tafsir. Calm, spacious, minimal motion, zero clutter.
- Beautiful empty states and illustrations. No generic Material defaults.
- Dark mode is a first-class theme, not an afterthought.

### 8.1 Design v2: Liquid Glass

- Glass on navigation layer only (bars, floating controls, sheets). Never on content lists. The Quran reader screen must remain calm with no glass over the ayah list.
- Never stack glass on glass. Elements above a glass bar use gradient fills.
- Regular glass variant by default. Clear variant only over media-rich content and must auto-add a dimming layer.
- Emulate lensing with a specular top highlight and gradient edge border, not plain blur.
- Adaptive tinting: light mode warm white tint, dark mode deep surface tint. Shadows strengthen when content scrolls beneath.
- Elderly Mode: reduce blur sigma, disable glow and flex animations.
- Performance: max one BackdropFilter per screen region, no nested blurs, never animate blur radius, wrap glass zones in RepaintBoundary.
- QA: scroll edge fade heights are tokens in AppSpacing (hard 24 soft 32) and must be re-evaluated on a physical device; any change updates both AppSpacing and this section in the same commit.

---

## 9. Navigation and v1 scope

Bottom navigation (matches approved design boards): Home, Quran, Qibla, Tasbih. Profile and Settings via top bar.

P0, must ship:
- Onboarding: optional name for greeting, daily goal choice (minimum 1 ayah), location or manual city, prayer calculation method, notification opt-in, language (English first)
- Home dashboard: personalized greeting, next prayer countdown with glowing ring, daily goal ring, weekly streak tracker, Hasanat ticker, tool grid
- Quran reader: Mushaf page-image mode (Madani) and text mode (Uthmani plus translation), last-read resume, bookmarks, favorites, offline search (Arabic and English)
- Audio player: stream from our CDN, speed control, continue on reopen
- Prayer times: offline calculation, method override, notifications
- Qibla: compass with device angle guidance
- Tasbih: digital counter with haptics and presets
- Gamification engine: goals, streaks, streak freeze, Hasanat, levels, badges
- Settings: dark mode, Elderly Mode, font sizes, translation choice, calculation method, data downloads, analytics opt-in, export and delete my data
- About and Credits screen
- Support page: transparent Sadaqah Jariyah donation entry

P1, same release:
- Reminders: prayer notifications plus daily reading reminder at user-chosen time
- Duas collection: curated verified set with attribution
- Family circles: private, invite-code, weekly leaderboard, remind nudges

P2, immediately after release:
- Memorize (hifz) tools with repeat-audio mode
- Ruqyah collection from verified sources
- Books library (open-license titles only)
- Dua Q&A as curated scholar-reviewed static dataset

---

## 10. Gamification specification

- Daily goal: minutes or ayah count, user-set, minimum 1 ayah.
- Streak: increments when daily goal is met. Missed day consumes one stored freeze if available.
- Streak freeze: earned per completed 7-day streak, capped storage (example cap 3).
- Hasanat ticker: base 10 per ayah as encouragement, with the disclaimer microcopy from section 3.
- Levels (our own names, respectful and playful): First Light, Dawn, Sunrise, Morning, Golden Hour, Full Moon, Radiant, Luminous, Enlightened. Thresholds defined in one constants file.
- Badges for milestones: first read, 7-day streak, 30-day streak, first khatmah progress markers, first tasbih thousand.
- Celebrations: Lottie plus haptics on goal completion and badge unlock. Never on sacred screens.
- Leaderboard: private family circles only. Shows chosen display name and weekly minutes or goal-hits only. No global public ranking.

---

## 11. Performance targets

- Cold start under 2.5 seconds on mid-range Android.
- Home visible under 500 ms after process start.
- Quran reader scrolling stable at 60 fps.
- Offline search results under 300 ms.
- App must open and be fully readable offline with zero network.
- No blocking calls at startup. No mandatory login. No forced onboarding after first setup.
- Base APK under 80 MB. Mushaf images and audio are on-demand download packs, never bundled in the base install.
- Images: proper caching, downsampling, CDN compression.

---

## 12. Privacy and security

- Guest-first. Accounts optional and only for sync plus family circles.
- No ads. No data selling. No third-party ad SDKs ever.
- Location computed and stored on-device. Synced only if the user explicitly enables sync.
- Analytics opt-in, minimal events, never log which verses were read, never log search text.
- GDPR-ready: export my data and delete my data in Settings.
- Supabase row-level security for any synced data.

---

## 13. Accessibility

- Dynamic type support across all screens.
- WCAG AA contrast in both themes.
- Full RTL layout support when Arabic UI is selected.
- Elderly Mode: larger base text, simplified bottom navigation, reduced motion and gamification.
- Semantic labels for screen readers, including for Arabic content.
- Minimum 48 dp tap targets.

---

## 14. Testing strategy

- Fakes over mocks, following the spirit of quran_android TESTING_STRATEGY.md.
- Real in-memory drift databases in tests.
- Widget tests for Home, Reader, Prayer, Qibla, Tasbih.
- Golden tests for reader typography and page-image overlay alignment.
- scripts/verify_quran_integrity.dart runs in CI on every PR.
- CI on GitHub Actions: dart format check, flutter analyze, flutter test, integrity script. All must pass to merge.

---

## 15. Git and workflow

- main: stable only. develop: integration. feature/*: tasks. review/*: corrections.
- Conventional commit messages.
- No direct commits to main or develop.
- Every task ends on a feature branch; Rasik merges after CTO review and device testing.
- Releases tagged from main with CHANGELOG entries.

---

## 16. Release policy

- No public launch without a 48-hour geofenced soft launch in one community.
- Crash-free rate and reader rendering errors monitored before global rollout.
- Target window: public launch before Ramadan 2027.

---

## 17. Anti-AI-feel checklist

The app must avoid:
- Generic Material widgets without customization
- Random gradients and excessive cards
- Inconsistent spacing, font sizes, or radii
- Robotic copywriting and lorem-ipsum-like strings
- Stock-looking icons and placeholder illustrations
- Slow or janky animations

The app must include:
- A consistent spacing and radius system
- Bespoke microcopy with warm, human tone
- Custom progress rings and counters via CustomPainter
- Meaningful micro-interactions and haptics
- Careful Arabic typography with correct line heights and justification
- Natural Islamic greetings and reminders language
- Polished empty, loading, and error states

---

## 18. Task protocol summary

For every task output:
1. Changed file tree
2. Commands run and their results
3. Dependencies added, with justification
4. Decisions and assumptions
5. Open questions for CTO review

Never ship: unverified religious text, hardcoded secrets, network calls on the startup path, or UI that violates section 17.