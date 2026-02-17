import 'package:oklab/src/conversions.dart';
import 'package:oklab/src/math_utils.dart';
import 'package:test/test.dart';

void main() {
  group('reference values', () {
    test('black and white', () {
      final black = linearSrgbToOklab(0.0, 0.0, 0.0);
      final white = linearSrgbToOklab(1.0, 1.0, 1.0);

      expect(black.lightness, closeTo(0.0, 1e-12));
      expect(black.a, closeTo(0.0, 1e-7));
      expect(black.b, closeTo(0.0, 1e-7));

      expect(white.lightness, closeTo(1.0, 1e-8));
      expect(white.a, closeTo(0.0, 1e-7));
      expect(white.b, closeTo(0.0, 1e-7));
    });

    test('linear sRGB primaries', () {
      final red = linearSrgbToOklab(1.0, 0.0, 0.0);
      final green = linearSrgbToOklab(0.0, 1.0, 0.0);
      final blue = linearSrgbToOklab(0.0, 0.0, 1.0);

      expect(red.lightness, closeTo(0.6279553606146, 1e-12));
      expect(red.a, closeTo(0.22486306106597, 1e-12));
      expect(red.b, closeTo(0.12584629853074, 1e-12));

      expect(green.lightness, closeTo(0.86643961153567, 1e-12));
      expect(green.a, closeTo(-0.23388757418791, 1e-12));
      expect(green.b, closeTo(0.17949847989673, 1e-12));

      expect(blue.lightness, closeTo(0.45201371838534, 1e-12));
      expect(blue.a, closeTo(-0.032456984168764, 1e-12));
      expect(blue.b, closeTo(-0.31152814767838, 1e-12));
    });
  });

  group('round-trip accuracy', () {
    test('sRGB -> Oklab -> sRGB stays within +/- 1 code value', () {
      const values = <int>[0, 32, 64, 128, 192, 255];

      for (final r in values) {
        for (final g in values) {
          for (final b in values) {
            final linearR = srgbToLinear(r / 255.0);
            final linearG = srgbToLinear(g / 255.0);
            final linearB = srgbToLinear(b / 255.0);

            final oklab = linearSrgbToOklab(linearR, linearG, linearB);
            final linear = oklabToLinearSrgb(oklab.lightness, oklab.a, oklab.b);

            final outR = (clamp01(linearToSrgb(linear.r)) * 255.0).round();
            final outG = (clamp01(linearToSrgb(linear.g)) * 255.0).round();
            final outB = (clamp01(linearToSrgb(linear.b)) * 255.0).round();

            expect((outR - r).abs(), lessThanOrEqualTo(1));
            expect((outG - g).abs(), lessThanOrEqualTo(1));
            expect((outB - b).abs(), lessThanOrEqualTo(1));
          }
        }
      }
    });
  });

  group('edge behavior', () {
    test('powerless hue maps to null', () {
      final oklch = oklabToOklch(0.5, 0.0, 0.0);
      expect(oklch.chroma, 0.0);
      expect(oklch.hue, isNull);
    });

    test('near-epsilon chroma controls hue powerlessness', () {
      final weak = oklabToOklch(0.5, kOklchHueEpsilon * 0.5, 0.0);
      final strong = oklabToOklch(0.5, kOklchHueEpsilon * 2.0, 0.0);

      expect(weak.hue, isNull);
      expect(strong.hue, 0.0);
    });

    test('oklch with missing hue converts to achromatic oklab', () {
      final lab = oklchToOklab(0.7, 0.2, null);
      expect(lab.a, 0.0);
      expect(lab.b, 0.0);
    });
  });
}
