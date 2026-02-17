import 'conversions.dart';
import 'math_utils.dart';

/// Returns `true` if an Oklch color maps inside the sRGB gamut.
///
/// [lightness] is normalized to `[0, 1]`, [chroma] is normalized to be
/// non-negative, and [hue] is normalized to `[0, 360)` when provided.
///
/// If [hue] is `null`, the color is only considered valid when [chroma] is
/// powerless (near zero).
bool isOklchInSrgbGamut(
  double lightness,
  double chroma,
  double? hue,
) {
  final normalizedLightness = normalizeUnitInterval(lightness);
  final normalizedChroma = normalizeNonNegative(chroma);
  final normalizedHue = normalizeOptionalHue(hue);

  if (normalizedHue == null) {
    return isPowerlessOklchHue(normalizedChroma);
  }

  return _isInSrgbGamut(normalizedLightness, normalizedChroma, normalizedHue);
}

/// Returns the maximum in-gamut Oklch chroma for [lightness] and [hue].
///
/// The search is performed in linear sRGB space and returns the largest chroma
/// value found that still maps into the `[0, 1]` gamut for all channels.
///
/// [lightness] is normalized to `[0, 1]` and [hue] is normalized to
/// `[0, 360)`.
///
/// [tolerance] controls binary-search precision and must be positive.
/// [maxIterations] controls search cost and must be at least `1`.
double maxOklchChroma(
  double lightness,
  double hue, {
  double tolerance = 1e-6,
  int maxIterations = 30,
}) {
  _validateSearchParams(tolerance, maxIterations);

  final normalizedLightness = normalizeUnitInterval(lightness);
  final normalizedHue = normalizeHueDegrees(hue);

  if (normalizedLightness == 0.0 || normalizedLightness == 1.0) {
    return 0.0;
  }

  var low = 0.0;
  var high = 0.5;

  while (_isInSrgbGamut(normalizedLightness, high, normalizedHue) && high < _kMaxSearchChroma) {
    low = high;
    high *= 2.0;
  }

  if (high > _kMaxSearchChroma) {
    high = _kMaxSearchChroma;
  }

  for (var i = 0; i < maxIterations && (high - low) > tolerance; i++) {
    final mid = (low + high) * 0.5;
    if (_isInSrgbGamut(normalizedLightness, mid, normalizedHue)) {
      low = mid;
    } else {
      high = mid;
    }
  }

  return low;
}

/// Clamps [chroma] to the largest sRGB-gamut-safe Oklch chroma value.
///
/// [lightness] is normalized to `[0, 1]`, [chroma] is normalized to be
/// non-negative, and [hue] is normalized to `[0, 360)` when provided.
///
/// If [hue] is `null`, this returns `0.0` (achromatic).
double clampOklchChromaToSrgbGamut(
  double lightness,
  double chroma,
  double? hue, {
  double tolerance = 1e-6,
  int maxIterations = 30,
}) {
  _validateSearchParams(tolerance, maxIterations);

  final normalizedLightness = normalizeUnitInterval(lightness);
  final normalizedChroma = normalizeNonNegative(chroma);
  final normalizedHue = normalizeOptionalHue(hue);

  if (normalizedChroma == 0.0 || normalizedHue == null) {
    return 0.0;
  }

  if (_isInSrgbGamut(normalizedLightness, normalizedChroma, normalizedHue)) {
    return normalizedChroma;
  }

  final maxChroma = maxOklchChroma(
    normalizedLightness,
    normalizedHue,
    tolerance: tolerance,
    maxIterations: maxIterations,
  );
  return normalizedChroma < maxChroma ? normalizedChroma : maxChroma;
}

const double _kGamutEpsilon = 1e-12;
const double _kMaxSearchChroma = 4.0;

bool _isInSrgbGamut(double lightness, double chroma, double hue) {
  final oklab = oklchToOklab(lightness, chroma, hue);
  final rgb = oklabToLinearSrgb(oklab.lightness, oklab.a, oklab.b);
  return _isUnitInterval(rgb.r) && _isUnitInterval(rgb.g) && _isUnitInterval(rgb.b);
}

bool _isUnitInterval(double value) {
  if (!value.isFinite) {
    return false;
  }

  return value >= -_kGamutEpsilon && value <= 1.0 + _kGamutEpsilon;
}

void _validateSearchParams(double tolerance, int maxIterations) {
  if (!tolerance.isFinite || tolerance <= 0.0) {
    throw ArgumentError.value(
      tolerance,
      'tolerance',
      'Must be a finite positive number.',
    );
  }
  if (maxIterations < 1) {
    throw ArgumentError.value(
      maxIterations,
      'maxIterations',
      'Must be at least 1.',
    );
  }
}
