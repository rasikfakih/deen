# Contributing to Deen

Thank you for contributing to a free, forever, offline-first Muslim toolkit. Please read `DEEN_AI_CONTEXT.md` first -- it is the source of truth if any doc conflicts.

## Branch Rules

| Branch | Purpose | Protections |
|--------|---------|-------------|
| `main` | Stable only. Tagged releases. | No direct commits. PR from `develop` only. Requires CTO review + device testing. |
| `develop` | Integration branch. | No direct commits. PR from `feature/*` or `review/*`. |
| `feature/*` | One task per branch (e.g. `feature/foundation`). | Created from `develop`. Squash or conventional commits. |
| `review/*` | Corrections after review. | Created from `feature/*` or `develop`. |

- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
- Never commit to `main` or `develop` directly.
- Every task ends on a feature branch; Rasik merges after CTO review and physical device testing.

## Quality Gates (must pass locally and in CI)

```bash
dart format .
flutter analyze
flutter test
dart run scripts/verify_quran_integrity.dart
```

CI on GitHub Actions runs all four on every PR. All must pass to merge. Keep `dagger`? No -- we use `flutter` only.

Additional rules:

- `dart format --set-exit-if-changed .` will fail CI if unformatted.
- `flutter analyze` must report `No issues found`.
- `flutter test` must be green (fakes over mocks, in-memory drift DBs).
- Integrity script must print `Quran Data Integrity Verified` and exit 0.

## AI-Generated Code Policy

- AI may write **code, tests, UI, tooling, and documentation ONLY**.
- **Never** generate, rewrite, paraphrase, summarize, translate, or modify religious content (Quran Arabic, translations, tafsir, hadith, duas, rulings). Religious content enters ONLY via `assets/data` produced by `scripts/fetch_quran_data.dart` and verified by checksums.
- **All AI-generated code requires human review** before merge. Mark PR description with `AI-assisted: yes` and the model used.
- Gamification copy must include the microcopy: "Counts are encouragement only; true reward is with Allah."

## Development Setup

```bash
flutter pub get
dart run scripts/fetch_quran_data.dart
dart run scripts/verify_quran_integrity.dart
flutter run
```

## Data Integrity

- Do not edit files under `assets/data/` by hand. Regenerate via the fetch script.
- If you add a dataset, update `DATA_SOURCES.md`, `CONTENT_LICENSES.md`, and `assets/data/checksums.sha256`.

## Code Style

- Null-safe, strongly typed, no dead code, no unexplained TODOs.
- Follow `analysis_options.yaml` (flutter_lints).
- Feature-first architecture: features never import each other; they import only `core` and `shared`.
- Sacred screens: calm, spacious, minimal motion. Playful screens: rich motion, haptics.

## Security

See `SECURITY.md`. Do not commit secrets. Use env files ignored by git.

## License

By contributing, you agree your code is licensed under GPL-3.0 (see `LICENSE` / `CONTENT_LICENSES.md`).