// Flutter imports:
import 'package:flutter/material.dart';

/// Validates and repairs a [ColorScheme] produced by the dynamic_color plugin.
///
/// On some devices (notably Samsung and Xiaomi) the plugin returns a
/// [ColorScheme] that is incomplete or degenerate: it may be grayscale only,
/// or the Material 3 surface container tones (`surfaceContainerLowest` …
/// `surfaceContainerHighest`) may be missing or transparent. [validate] returns
/// a usable, fully-populated scheme, or `null` when the scheme must fall back
/// to a seed-generated scheme.
class DynamicColorValidator {
  /// Returns a usable, repaired [ColorScheme], or null if degenerate.
  ///
  /// A scheme is considered degenerate when it is null or its primary color has
  /// zero saturation (grayscale only), meaning dynamic color failed to derive a
  /// usable accent from the wallpaper.
  static ColorScheme? validate(ColorScheme? colorScheme) {
    if (colorScheme == null) return null;

    final hslPrimary = HSLColor.fromColor(colorScheme.primary);
    if (hslPrimary.saturation <= 0.01) return null;

    return _repairSurfaceContainers(colorScheme);
  }

  /// Reconstructs the Material 3 surface container tones.
  ///
  /// `dynamic_color`'s `CorePalette.toColorScheme()` never forwards the
  /// `surfaceContainer*` tones, so Flutter falls back to `surface` for every
  /// container tone and cards become invisible. We always rebuild the ramp from
  /// the base surface tones (composited onto an opaque backdrop) so the result
  /// is fully opaque and distinct from the background.
  ///
  /// Returns `null` when the base tones (`surface`/`surfaceVariant`) are missing
  /// or fully transparent, in which case the whole scheme is unusable.
  static ColorScheme? _repairSurfaceContainers(ColorScheme scheme) {
    bool isPresent(Color? c) => c != null && c.a > 0;

    final surface = scheme.surface;
    final surfaceVariant = scheme.surfaceVariant;
    if (!isPresent(surface) || !isPresent(surfaceVariant)) return null;

    final opaqueBackdrop =
        scheme.brightness == Brightness.dark ? Colors.black : Colors.white;
    Color toOpaque(Color c) => c.a >= 1 ? c : Color.alphaBlend(c, opaqueBackdrop);

    final opaqueSurface = toOpaque(surface);
    final opaqueVariant = toOpaque(surfaceVariant);

    Color blend(double variantAmount) =>
        Color.alphaBlend(opaqueVariant.withValues(alpha: variantAmount), opaqueSurface);

    if (scheme.brightness == Brightness.light) {
      return scheme.copyWith(
        surfaceContainerLowest: opaqueSurface,
        surfaceContainerLow: blend(0.25),
        surfaceContainer: blend(0.50),
        surfaceContainerHigh: blend(0.75),
        surfaceContainerHighest: opaqueVariant,
      );
    }

    final lowest = Color.alphaBlend(opaqueSurface.withValues(alpha: 0.30), opaqueBackdrop);
    return scheme.copyWith(
      surfaceContainerLowest: lowest,
      surfaceContainerLow: blend(0.17),
      surfaceContainer: blend(0.25),
      surfaceContainerHigh: blend(0.46),
      surfaceContainerHighest: blend(0.67),
    );
  }
}
