import 'package:oklab/src/math_utils.dart';
import 'package:test/test.dart';

void main() {
  group('srgb transfer functions', () {
    test('known values', () {
      expect(srgbToLinear(0.0), 0.0);
      expect(srgbToLinear(1.0), closeTo(1.0, 1e-12));
      expect(srgbToLinear(0.5), closeTo(0.214041140482, 1e-12));

      expect(linearToSrgb(0.0), 0.0);
      expect(linearToSrgb(1.0), closeTo(1.0, 1e-12));
      expect(linearToSrgb(0.214041140482), closeTo(0.5, 1e-12));
    });

    test('round-trip for positive and negative values', () {
      const samples = <double>[-1.0, -0.5, -0.04, 0.0, 0.02, 0.5, 1.0];

      for (final value in samples) {
        final encoded = linearToSrgb(value);
        final decoded = srgbToLinear(encoded);
        expect(decoded, closeTo(value, 1e-12), reason: 'value=$value');
      }
    });
  });

  group('helpers', () {
    test('clamp01', () {
      expect(clamp01(-1.0), 0.0);
      expect(clamp01(0.25), 0.25);
      expect(clamp01(2.0), 1.0);
      expect(clamp01(double.nan), 0.0);
    });

    test('normalizeHueDegrees', () {
      expect(normalizeHueDegrees(-30.0), 330.0);
      expect(normalizeHueDegrees(360.0), 0.0);
      expect(normalizeHueDegrees(725.0), 5.0);
      expect(normalizeHueDegrees(double.nan), 0.0);
    });

    test('powerless hue epsilon', () {
      expect(isPowerlessOklchHue(0.0), isTrue);
      expect(isPowerlessOklchHue(kOklchHueEpsilon), isTrue);
      expect(isPowerlessOklchHue(kOklchHueEpsilon + 0.000001), isFalse);
    });
  });
}
