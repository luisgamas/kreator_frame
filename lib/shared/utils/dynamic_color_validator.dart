// Flutter imports:
import 'package:flutter/material.dart';

/// Validates whether a [ColorScheme] from dynamic_color is actually usable.
///
/// On some devices (notably Samsung and Xiaomi), the dynamic_color library
/// may return a [ColorScheme] that is non-null but has degenerate values
/// (e.g., primary and secondary being the same shade). This validator
/// detects such cases and returns null to trigger the fallback.
class DynamicColorValidator {

  /// Minimum hue difference (in degrees) between primary and secondary
  /// for the scheme to be considered valid.
  static const double _minHueDifference = 5.0;

  /// Returns [colorScheme] if it's valid, or null if degenerate.
  ///
  /// A scheme is considered degenerate when:
  /// - It is null
  /// - Primary and secondary hues are nearly identical (less than 5° apart)
  /// - Primary color has zero saturation (grayscale only)
  static ColorScheme? validate(ColorScheme? colorScheme) {
    if (colorScheme == null) return null;

    final hslPrimary = HSLColor.fromColor(colorScheme.primary);
    final hslSecondary = HSLColor.fromColor(colorScheme.secondary);

    // Check primary is not grayscale (saturation > 0)
    if (hslPrimary.saturation <= 0.01) {
      return null;
    }

    // Check primary and secondary are visually distinct
    final hueDifference = (hslPrimary.hue - hslSecondary.hue).abs();
    final wrappedDifference = hueDifference > 180
        ? 360 - hueDifference
        : hueDifference;

    if (wrappedDifference < _minHueDifference) {
      return null;
    }

    return colorScheme;
  }
}