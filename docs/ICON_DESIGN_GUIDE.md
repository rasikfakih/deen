# Icon Design Guide - Deen

Founder-crafted SVG registry. Replace any placeholder in `assets/icons/` with final artwork - zero code changes required.

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

## Inventory (41 placeholders awaiting founder artwork)

| Name | File | Description | Status |
|------|------|-------------|--------|
| ic_home | ic_home.svg | House outline | placeholder |
| ic_quran | ic_quran.svg | Book | placeholder |
| ic_qibla | ic_qibla.svg | Compass | placeholder |
| ic_tasbih | ic_tasbih.svg | Circle with dot | placeholder |
| ic_settings | ic_settings.svg | Gear | placeholder |
| ic_search | ic_search.svg | Magnifier | placeholder |
| ic_bookmark | ic_bookmark.svg | Ribbon outline | placeholder |
| ic_bookmark_filled | ic_bookmark_filled.svg | Ribbon solid | placeholder |
| ic_share | ic_share.svg | Arrow box | placeholder |
| ic_close | ic_close.svg | X | placeholder |
| ic_back | ic_back.svg | Chevron left | placeholder |
| ic_copy | ic_copy.svg | Docs | placeholder |
| ic_external | ic_external.svg | Arrow out | placeholder |
| ic_play | ic_play.svg | Triangle | placeholder |
| ic_pause | ic_pause.svg | Bars | placeholder |
| ic_speed | ic_speed.svg | Gauge | placeholder |
| ic_next | ic_next.svg | Chevron right | placeholder |
| ic_prev | ic_prev.svg | Chevron left small | placeholder |
| ic_fajr | ic_fajr.svg | Dawn | placeholder |
| ic_sunrise | ic_sunrise.svg | Sunrise | placeholder |
| ic_dhuhr | ic_dhuhr.svg | Sun overhead | placeholder |
| ic_asr | ic_asr.svg | Sun afternoon | placeholder |
| ic_maghrib | ic_maghrib.svg | Sunset | placeholder |
| ic_isha | ic_isha.svg | Moon | placeholder |
| ic_location | ic_location.svg | Pin | placeholder |
| ic_bell | ic_bell.svg | Bell | placeholder |
| ic_clock | ic_clock.svg | Clock | placeholder |
| ic_streak | ic_streak.svg | Flame | placeholder |
| ic_freeze | ic_freeze.svg | Snowflake | placeholder |
| ic_hasanat | ic_hasanat.svg | Star | placeholder |
| ic_target | ic_target.svg | Crosshair | placeholder |
| ic_trophy | ic_trophy.svg | Cup | placeholder |
| ic_badge_star | ic_badge_star.svg | Badge star | placeholder |
| ic_family | ic_family.svg | Users | placeholder |
| ic_invite | ic_invite.svg | Mail | placeholder |
| ic_heart | ic_heart.svg | Heart | placeholder |
| ic_check | ic_check.svg | Check | placeholder |
| ic_chevron_right | ic_chevron_right.svg | Chevron right | placeholder |
| ic_chevron_left | ic_chevron_left.svg | Chevron left | placeholder |
| ic_moon | ic_moon.svg | Moon | placeholder |
| ic_sun | ic_sun.svg | Sun | placeholder |

## Drop-in workflow

1. Craft final SVG in Figma (24x24, 1.8 stroke, round caps).
2. Export as SVG, ensure `stroke="currentColor"` and `fill="none"`.
3. Replace `assets/icons/<name>.svg` - keep same filename.
4. `flutter test` and `flutter analyze` - no code change, hot reload shows new icon.

## Notes

- Do not add new names without updating `DeenIcons` registry.
- Keep `stroke-width 1.8` uniform (per CTO). Simplify geometry if icon feels dense, do not thin stroke.
- Test in both light (`#F9F6F0`) and dark (`#121212`) with `AppColors` tints.
