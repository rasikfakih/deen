# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x (main) | Yes |
| < 1.0 pre-release | Best effort |

## Reporting a Vulnerability

- Email: security@rasikfakih.com (placeholder -- update before public launch)
- Or open a **private** GitHub Security Advisory on this repository.

Please include:
- Description, impact, and reproduction steps
- Affected version / commit hash
- Whether the issue touches religious content integrity

We will acknowledge within 72 hours and aim to patch critical issues within 7 days.

## What We Protect

- Sacred content integrity: every `assets/data` file is SHA-256 checksummed and verified at build (`scripts/verify_quran_integrity.dart`). Builds fail on mismatch.
- User data: guest-first, optional sync via Supabase row-level security (RLS). Location never leaves device unless user enables sync.
- No hardcoded secrets. Secrets are injected via environment variables / secure storage and never committed.

## Disclosure

Once fixed, we publish a `SECURITY.md` changelog entry and tag a patch release. Please allow us coordinated disclosure before public posting.

## No Data Selling, No Ads

We will never add third-party ad SDKs. Analytics is opt-in only and never logs which verses were read or search text.