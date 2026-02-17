import 'dart:ui' show Color;

import 'package:oklab/oklab.dart';

/// Converts [color] from Oklab to Flutter [Color].
Color colorFromOklab(OklabColor color) {
  final rgb = color.toRgb();
  return colorFromRgbTuple(rgb);
}

/// Converts [color] from Oklch to Flutter [Color].
Color colorFromOklch(OklchColor color) {
  final rgb = color.toRgb();
  return colorFromRgbTuple(rgb);
}

/// Creates Flutter [Color] from an `(r, g, b, alpha)` tuple.
///
/// RGB channels must be in `[0, 255]`.
/// The `alpha` value is interpreted in `[0, 1]` and clamped to 8-bit alpha.
Color colorFromRgbTuple((int r, int g, int b, double alpha) rgb) {
  final (r, g, b, alpha) = rgb;
  final alpha8 = (alpha * 255.0).round().clamp(0, 255);
  return Color.fromARGB(alpha8, r, g, b);
}
