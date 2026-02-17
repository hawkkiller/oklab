import 'conversions.dart';
import 'math_utils.dart';
import 'oklab_color.dart';

final class OklchColor {
  static const Object _hueSentinel = Object();

  final double lightness;
  final double chroma;
  final double? hue;
  final double alpha;

  factory OklchColor(
    double lightness,
    double chroma,
    double? hue, [
    double alpha = 1.0,
  ]) {
    final normalizedLightness = normalizeUnitInterval(lightness);
    final normalizedChroma = normalizeNonNegative(chroma);
    final normalizedAlpha = normalizeUnitInterval(alpha);

    final normalizedHue = isPowerlessOklchHue(normalizedChroma) ? null : normalizeOptionalHue(hue);

    return OklchColor._raw(
      normalizedLightness,
      normalizedChroma,
      normalizedHue,
      normalizedAlpha,
    );
  }

  /// Creates a value without normalization or validation.
  factory OklchColor.raw(
    double lightness,
    double chroma,
    double? hue, [
    double alpha = 1.0,
  ]) {
    return OklchColor._raw(lightness, chroma, hue, alpha);
  }

  const OklchColor._raw(this.lightness, this.chroma, this.hue, this.alpha);

  OklabColor toOklab() {
    final oklab = oklchToOklab(lightness, chroma, hue);
    return OklabColor(oklab.lightness, oklab.a, oklab.b, alpha);
  }

  (int r, int g, int b, double alpha) toRgb() => toOklab().toRgb();

  OklchColor lerp(OklchColor other, double t) {
    if (t <= 0.0) {
      return this;
    }
    if (t >= 1.0) {
      return other;
    }

    final nextLightness = _lerp(lightness, other.lightness, t);
    final nextChroma = _lerp(chroma, other.chroma, t);
    final nextAlpha = _lerp(alpha, other.alpha, t);
    final nextHue = _lerpHue(hue, other.hue, t);

    return OklchColor(nextLightness, nextChroma, nextHue, nextAlpha);
  }

  OklchColor copyWith({
    double? lightness,
    double? chroma,
    Object? hue = _hueSentinel,
    double? alpha,
  }) {
    final nextHue = _resolveCopyWithHue(hue, this.hue);

    return OklchColor(
      lightness ?? this.lightness,
      chroma ?? this.chroma,
      nextHue,
      alpha ?? this.alpha,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OklchColor &&
            lightness == other.lightness &&
            chroma == other.chroma &&
            hue == other.hue &&
            alpha == other.alpha;
  }

  @override
  int get hashCode => Object.hash(lightness, chroma, hue, alpha);

  @override
  String toString() {
    return 'OklchColor('
        'lightness: $lightness, '
        'chroma: $chroma, '
        'hue: $hue, '
        'alpha: $alpha'
        ')';
  }
}

double _lerp(double start, double end, double t) => start + (end - start) * t;

double? _lerpHue(double? fromHue, double? toHue, double t) {
  if (t <= 0.0) {
    return fromHue == null ? null : normalizeHueDegrees(fromHue);
  }
  if (t >= 1.0) {
    return toHue == null ? null : normalizeHueDegrees(toHue);
  }

  if (fromHue == null && toHue == null) {
    return null;
  }

  if (fromHue == null) {
    return normalizeHueDegrees(toHue!);
  }

  if (toHue == null) {
    return normalizeHueDegrees(fromHue);
  }

  final start = normalizeHueDegrees(fromHue);
  final end = normalizeHueDegrees(toHue);
  var delta = end - start;

  if (delta > 180.0) {
    delta -= 360.0;
  } else if (delta < -180.0) {
    delta += 360.0;
  }

  return normalizeHueDegrees(start + delta * t);
}

double? _resolveCopyWithHue(Object? hueArg, double? currentHue) {
  if (identical(hueArg, OklchColor._hueSentinel)) {
    return currentHue;
  }
  if (hueArg == null) {
    return null;
  }
  if (hueArg is num) {
    return hueArg.toDouble();
  }

  throw ArgumentError.value(
    hueArg,
    'hue',
    'must be a number, null, or omitted',
  );
}
