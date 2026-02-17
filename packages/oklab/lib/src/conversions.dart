import 'dart:math' as math;

import 'math_utils.dart';

({double lightness, double a, double b}) linearSrgbToOklab(
  double r,
  double g,
  double b,
) {
  final l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
  final m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
  final s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

  final lRoot = cubeRootSigned(l);
  final mRoot = cubeRootSigned(m);
  final sRoot = cubeRootSigned(s);

  final lightness =
      0.2104542553 * lRoot + 0.7936177850 * mRoot - 0.0040720468 * sRoot;
  final a = 1.9779984951 * lRoot - 2.4285922050 * mRoot + 0.4505937099 * sRoot;
  final labB =
      0.0259040371 * lRoot + 0.7827717662 * mRoot - 0.8086757660 * sRoot;

  return (lightness: lightness, a: a, b: labB);
}

({double r, double g, double b}) oklabToLinearSrgb(
  double lightness,
  double a,
  double b,
) {
  final lRoot = lightness + 0.3963377774 * a + 0.2158037573 * b;
  final mRoot = lightness - 0.1055613458 * a - 0.0638541728 * b;
  final sRoot = lightness - 0.0894841775 * a - 1.2914855480 * b;

  final l = lRoot * lRoot * lRoot;
  final m = mRoot * mRoot * mRoot;
  final s = sRoot * sRoot * sRoot;

  final r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  final g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  final rgbB = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

  return (r: r, g: g, b: rgbB);
}

({double lightness, double chroma, double? hue}) oklabToOklch(
  double lightness,
  double a,
  double b,
) {
  final chroma = math.sqrt(a * a + b * b);
  if (isPowerlessOklchHue(chroma)) {
    return (lightness: lightness, chroma: chroma, hue: null);
  }

  final hue = normalizeHueDegrees(math.atan2(b, a) * (180.0 / math.pi));
  return (lightness: lightness, chroma: chroma, hue: hue);
}

({double lightness, double a, double b}) oklchToOklab(
  double lightness,
  double chroma,
  double? hue,
) {
  if (hue == null || isPowerlessOklchHue(chroma)) {
    return (lightness: lightness, a: 0.0, b: 0.0);
  }

  final normalizedHue = normalizeHueDegrees(hue);
  final radians = normalizedHue * (math.pi / 180.0);
  final a = chroma * math.cos(radians);
  final b = chroma * math.sin(radians);
  return (lightness: lightness, a: a, b: b);
}
