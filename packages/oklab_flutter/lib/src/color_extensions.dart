import 'dart:ui' show Color;

import 'package:oklab/oklab.dart';

import 'color_factories.dart';

/// Adds Oklab/Oklch conversion methods to Flutter [Color].
extension OklabColorExtension on Color {
  /// Converts this [Color] to [OklabColor].
  OklabColor toOklab() {
    final argb = toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    final alpha = ((argb >> 24) & 0xFF) / 255.0;

    return OklabColor.fromRgb(r, g, b, alpha);
  }

  /// Converts this [Color] to [OklchColor].
  OklchColor toOklch() => toOklab().toOklch();
}

/// Adds conversion from [OklabColor] to Flutter [Color].
extension OklabToColorExtension on OklabColor {
  /// Converts this [OklabColor] to Flutter [Color].
  Color toColor() => colorFromOklab(this);
}

/// Adds conversion from [OklchColor] to Flutter [Color].
extension OklchToColorExtension on OklchColor {
  /// Converts this [OklchColor] to Flutter [Color].
  Color toColor() => colorFromOklch(this);
}
