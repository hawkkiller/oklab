import 'dart:ui' show Color;

import 'package:oklab/oklab.dart';

Color colorFromOklab(OklabColor color) {
  final rgb = color.toRgb();
  return colorFromRgbTuple(rgb);
}

Color colorFromOklch(OklchColor color) {
  final rgb = color.toRgb();
  return colorFromRgbTuple(rgb);
}

Color colorFromRgbTuple((int r, int g, int b, double alpha) rgb) {
  final (r, g, b, alpha) = rgb;
  final alpha8 = (alpha * 255.0).round().clamp(0, 255);
  return Color.fromARGB(alpha8, r, g, b);
}
