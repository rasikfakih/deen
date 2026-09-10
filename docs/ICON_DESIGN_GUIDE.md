# Icon Design Guide - Deen

SVG registry: 31 Lucide library glyphs (ISC, stroke-normalized to 1.8) plus a 10-icon custom identity set. Any icon can be elevated to founder-crafted later by replacing its SVG file with no code change.

## Spec

- Size: 24x24, viewBox `0 0 24 24`
- Stroke: `currentColor`, width `1.8`, `stroke-linecap round`, `stroke-linejoin round`, `fill none`
- Optical padding: 1.5px inset, keep 24dp bounds
- Style: minimalist geometric, monolinear, calm sacred layer - no filled solids except `ic_bookmark_filled` and `ic_heart` active states (still use `fill currentColor` for those two)
- Header: `<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" ...>`

## Usage

```dart
import 'package:deem/core/utils/deen_icons.dart'; // actually deen: lib/core/utils/deen_icons.dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deem/shared/widgets/glass/deen_gradient_icon.dart';

SvgPicture.asset(DeenIcons.ic_home, width: 24, height: 24, colorFilter: ColorFilter.mode(AppColors.textMuted, BlendMode.srcIn))
DeenGradientIcon(asset: DeenIcons.ic_quran, gradient: AppGradients.goldFlow)
```

Selected nav icons use `DeenGradientIcon` with `AppGradients.goldFlow 135deg`, unselected use muted `AppColors.textMuted` / dark `0xFF9E9589`.

## Inventory (41 icons: 31 library, 10 custom)

Provenance `library` = Lucide (ISC, stroke-normalized 1.8). Provenance `custom` = original Deen identity set. Any row can be elevated to founder-crafted later by replacing its SVG file with no code change.

Footnote: the filled variant (`ic_bookmark_filled.svg`) carries an inert `stroke-width` attribute alongside `stroke="none"` by design; verification expects 41 files with the attribute, not 40.

| Name | File | Description | Provenance | Status |
|------|------|-------------|------------|--------|
| ic_home | ic_home.svg | House outline (Lucide house) | library | library-v1 |
| ic_quran | ic_quran.svg | Book open | library | library-v1 |
| ic_qibla | ic_qibla.svg | Compass needle in circle | custom | custom-v1 |
| ic_tasbih | ic_tasbih.svg | Bead circle with strand | custom | custom-v1 |
| ic_settings | ic_settings.svg | Gear | library | library-v1 |
| ic_search | ic_search.svg | Magnifier | library | library-v1 |
| ic_bookmark | ic_bookmark.svg | Ribbon outline | library | library-v1 |
| ic_bookmark_filled | ic_bookmark_filled.svg | Ribbon solid | library | library-v1 |
| ic_share | ic_share.svg | Arrow box | library | library-v1 |
| ic_close | ic_close.svg | X | library | library-v1 |
| ic_back | ic_back.svg | Arrow left | library | library-v1 |
| ic_copy | ic_copy.svg | Docs | library | library-v1 |
| ic_external | ic_external.svg | Arrow out | library | library-v1 |
| ic_play | ic_play.svg | Triangle | library | library-v1 |
| ic_pause | ic_pause.svg | Bars | library | library-v1 |
| ic_speed | ic_speed.svg | Gauge | library | library-v1 |
| ic_next | ic_next.svg | Skip forward | library | library-v1 |
| ic_prev | ic_prev.svg | Skip back | library | library-v1 |
| ic_fajr | ic_fajr.svg | Dawn horizon | custom | custom-v1 |
| ic_sunrise | ic_sunrise.svg | Sunrise arrow up | custom | custom-v1 |
| ic_dhuhr | ic_dhuhr.svg | Sun overhead full rays | custom | custom-v1 |
| ic_asr | ic_asr.svg | Sun low partial rays | custom | custom-v1 |
| ic_maghrib | ic_maghrib.svg | Sunset arrow down | custom | custom-v1 |
| ic_isha | ic_isha.svg | Crescent moon and star | custom | custom-v1 |
| ic_location | ic_location.svg | Pin | library | library-v1 |
| ic_bell | ic_bell.svg | Bell | library | library-v1 |
| ic_clock | ic_clock.svg | Clock | library | library-v1 |
| ic_streak | ic_streak.svg | Flame | library | library-v1 |
| ic_freeze | ic_freeze.svg | Snowflake | library | library-v1 |
| ic_hasanat | ic_hasanat.svg | Four-point sparkle | custom | custom-v1 |
| ic_target | ic_target.svg | Crosshair | library | library-v1 |
| ic_trophy | ic_trophy.svg | Cup | library | library-v1 |
| ic_badge_star | ic_badge_star.svg | Eight-point star badge | custom | custom-v1 |
| ic_family | ic_family.svg | Users | library | library-v1 |
| ic_invite | ic_invite.svg | User plus | library | library-v1 |
| ic_heart | ic_heart.svg | Heart | library | library-v1 |
| ic_check | ic_check.svg | Check | library | library-v1 |
| ic_chevron_right | ic_chevron_right.svg | Chevron right | library | library-v1 |
| ic_chevron_left | ic_chevron_left.svg | Chevron left | library | library-v1 |
| ic_moon | ic_moon.svg | Moon | library | library-v1 |
| ic_sun | ic_sun.svg | Sun | library | library-v1 |

## Drop-in workflow

1. Craft final SVG in Figma (24x24, 1.8 stroke, round caps).
2. Export as SVG, ensure `stroke="currentColor"` and `fill="none"`.
3. Replace `assets/icons/<name>.svg` - keep same filename.
4. `flutter test` and `flutter analyze` - no code change, hot reload shows new icon.

## Notes

- Do not add new names without updating `DeenIcons` registry.
- Keep `stroke-width 1.8` uniform (per CTO). Simplify geometry if icon feels dense, do not thin stroke.
- Test in both light (`#F9F6F0`) and dark (`#121212`) with `AppColors` tints.
