# Privacy Principles

Deen is guest-first and privacy by default. These principles are enforced in code and product decisions.

## 1. Guest-First, Account Optional

- The app works fully offline with zero network and no mandatory login.
- Accounts (via Supabase) are optional and only for sync and family circles.
- No forced onboarding after first setup.

## 2. No Ads, No Data Selling, No Third-Party Ad SDKs -- Ever

- We will never show ads or sell data.
- Optional Sadaqah Jariyah donations cover infrastructure only.

## 3. No Public Leaderboard

- Leaderboards are **private family circles only** (invite-code, weekly minutes/goal-hits).
- No global public ranking. No display of personal data beyond chosen display name.

## 4. Location On-Device

- Prayer times are computed on-device via the `adhan` package.
- Location is computed and stored on-device.
- Synced only if the user explicitly enables sync (Supabase RLS).

## 5. Analytics Opt-In

- Analytics (e.g. PostHog) is **opt-in** in Settings.
- Minimal events only. We never log which verses were read or search text.

## 6. Export and Delete My Data

- Settings includes **Export my data** and **Delete my data** (GDPR-ready).
- Sync-disabled users can delete local data by clearing app storage.

## 7. Data Minimization

- We collect only what is needed for core features (goals, streaks, bookmarks).
- Heavy database work runs off the main isolate; no blocking startup calls.

## 8. Transparency

- Open source (GPL-3.0). Data sources and licenses are documented in `DATA_SOURCES.md` and `CONTENT_LICENSES.md` and shown on the in-app About and Credits screen.
- This document is versioned; changes require CTO review.