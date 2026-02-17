import 'package:oklab/oklab.dart';
import 'package:test/test.dart';

void main() {
  group('isOklchInSrgbGamut', () {
    test('returns true for converted in-gamut sRGB colors', () {
      final oklch = OklabColor.fromRgb(120, 200, 80).toOklch();
      expect(isOklchInSrgbGamut(oklch.lightness, oklch.chroma, oklch.hue), isTrue);
    });

    test('returns false when chroma exceeds max for lightness and hue', () {
      const lightness = 0.7;
      const hue = 35.0;
      final maxChroma = maxOklchChroma(lightness, hue);
      expect(isOklchInSrgbGamut(lightness, maxChroma + 1e-4, hue), isFalse);
    });

    test('treats null hue as valid only for powerless chroma', () {
      expect(isOklchInSrgbGamut(0.5, 0.0, null), isTrue);
      expect(isOklchInSrgbGamut(0.5, 0.1, null), isFalse);
    });
  });

  group('maxOklchChroma', () {
    test('returns 0 at lightness boundaries', () {
      expect(maxOklchChroma(0.0, 30.0), 0.0);
      expect(maxOklchChroma(1.0, 30.0), 0.0);
      expect(maxOklchChroma(-10.0, 30.0), 0.0);
      expect(maxOklchChroma(10.0, 30.0), 0.0);
    });

    test('normalizes hue degrees', () {
      final a = maxOklchChroma(0.65, -30.0);
      final b = maxOklchChroma(0.65, 330.0);
      final c = maxOklchChroma(0.65, 690.0);

      expect(a, closeTo(b, 1e-9));
      expect(b, closeTo(c, 1e-9));
    });

    test('result is in gamut and slightly above is out of gamut', () {
      const lightness = 0.7;
      const hue = 35.0;
      final chroma = maxOklchChroma(lightness, hue);

      expect(chroma, greaterThan(0.0));
      expect(isOklchInSrgbGamut(lightness, chroma, hue), isTrue);
      expect(isOklchInSrgbGamut(lightness, chroma + 1e-4, hue), isFalse);
    });

    test('validates search parameters', () {
      expect(
        () => maxOklchChroma(0.5, 42.0, tolerance: 0.0),
        throwsArgumentError,
      );
      expect(
        () => maxOklchChroma(0.5, 42.0, maxIterations: 0),
        throwsArgumentError,
      );
    });
  });

  group('clampOklchChromaToSrgbGamut', () {
    test('preserves in-gamut values', () {
      final oklch = OklabColor.fromRgb(48, 156, 220).toOklch();
      final clamped = clampOklchChromaToSrgbGamut(
        oklch.lightness,
        oklch.chroma,
        oklch.hue,
      );
      expect(clamped, closeTo(oklch.chroma, 1e-6));
    });

    test('clamps out-of-gamut chroma to boundary', () {
      const lightness = 0.7;
      const hue = 35.0;
      final clamped = clampOklchChromaToSrgbGamut(lightness, 1.0, hue);

      expect(isOklchInSrgbGamut(lightness, clamped, hue), isTrue);
      expect(isOklchInSrgbGamut(lightness, clamped + 1e-4, hue), isFalse);
    });

    test('returns 0 for missing hue', () {
      expect(clampOklchChromaToSrgbGamut(0.7, 0.2, null), 0.0);
    });

    test('validates search parameters', () {
      expect(
        () => clampOklchChromaToSrgbGamut(0.5, 0.2, 42.0, tolerance: 0.0),
        throwsArgumentError,
      );
      expect(
        () => clampOklchChromaToSrgbGamut(0.5, 0.2, 42.0, maxIterations: 0),
        throwsArgumentError,
      );
    });
  });
}
