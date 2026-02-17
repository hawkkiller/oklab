import 'conversions.dart';
import 'math_utils.dart';
import 'oklch_color.dart';

final class OklabColor {
  /// Perceptual lightness in the `[0, 1]` range after normalization.
  final double lightness;

  /// Opponent-axis component for green <-> red.
  ///
  /// Negative values are greener, positive values are redder.
  final double a;

  /// Opponent-axis component for blue <-> yellow.
  ///
  /// Negative values are bluer, positive values are yellower.
  final double b;

  /// Opacity in the `[0, 1]` range after normalization.
  final double alpha;

  factory OklabColor(
    double lightness,
    double a,
    double b, [
    double alpha = 1.0,
  ]) {
    return OklabColor._raw(
      normalizeUnitInterval(lightness),
      normalizeFiniteOrZero(a),
      normalizeFiniteOrZero(b),
      normalizeUnitInterval(alpha),
    );
  }

  /// Creates a value without normalization or validation.
  factory OklabColor.raw(
    double lightness,
    double a,
    double b, [
    double alpha = 1.0,
  ]) {
    return OklabColor._raw(lightness, a, b, alpha);
  }

  const OklabColor._raw(this.lightness, this.a, this.b, this.alpha);

  factory OklabColor.fromRgb(int r, int g, int b, [double alpha = 1.0]) {
    final sr = clampRgb8(r) / 255.0;
    final sg = clampRgb8(g) / 255.0;
    final sb = clampRgb8(b) / 255.0;

    final linearR = srgbToLinear(sr);
    final linearG = srgbToLinear(sg);
    final linearB = srgbToLinear(sb);
    final oklab = linearSrgbToOklab(linearR, linearG, linearB);

    return OklabColor(oklab.lightness, oklab.a, oklab.b, alpha);
  }

  OklchColor toOklch() {
    final oklch = oklabToOklch(lightness, a, b);
    return OklchColor(oklch.lightness, oklch.chroma, oklch.hue, alpha);
  }

  (int r, int g, int b, double alpha) toRgb() {
    final linear = oklabToLinearSrgb(lightness, a, b);

    final r = linearToSrgb(linear.r);
    final g = linearToSrgb(linear.g);
    final blue = linearToSrgb(linear.b);

    final rgbR = (clamp01(r) * 255.0).round();
    final rgbG = (clamp01(g) * 255.0).round();
    final rgbB = (clamp01(blue) * 255.0).round();

    return (rgbR, rgbG, rgbB, alpha);
  }

  OklabColor lerp(OklabColor other, double t) {
    return OklabColor(
      _lerp(lightness, other.lightness, t),
      _lerp(a, other.a, t),
      _lerp(b, other.b, t),
      _lerp(alpha, other.alpha, t),
    );
  }

  OklabColor copyWith({
    double? lightness,
    double? a,
    double? b,
    double? alpha,
  }) {
    return OklabColor(
      lightness ?? this.lightness,
      a ?? this.a,
      b ?? this.b,
      alpha ?? this.alpha,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OklabColor &&
            lightness == other.lightness &&
            a == other.a &&
            b == other.b &&
            alpha == other.alpha;
  }

  @override
  int get hashCode => Object.hash(lightness, a, b, alpha);

  @override
  String toString() {
    return 'OklabColor('
        'lightness: $lightness, '
        'a: $a, '
        'b: $b, '
        'alpha: $alpha'
        ')';
  }
}

double _lerp(double start, double end, double t) => start + (end - start) * t;
