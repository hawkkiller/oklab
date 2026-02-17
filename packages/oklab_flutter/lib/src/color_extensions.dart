import 'dart:ui' show Color;

import 'package:oklab/oklab.dart';

import 'color_factories.dart';

extension OklabColorExtension on Color {
  OklabColor toOklab() {
    final argb = toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    final alpha = ((argb >> 24) & 0xFF) / 255.0;

    return OklabColor.fromRgb(r, g, b, alpha);
  }

  OklchColor toOklch() => toOklab().toOklch();
}

extension OklabToColorExtension on OklabColor {
  Color toColor() => colorFromOklab(this);
}

extension OklchToColorExtension on OklchColor {
  Color toColor() => colorFromOklch(this);
}
