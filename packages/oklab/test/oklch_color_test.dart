import 'package:oklab/oklab.dart';
import 'package:test/test.dart';

void main() {
  group('construction and value semantics', () {
    test('normalizes constructor inputs', () {
      final clamped = OklchColor(-1.0, -2.0, 725.0, 2.0);
      final normalizedHue = OklchColor(0.5, 0.2, 725.0, 1.0);

      expect(clamped.lightness, 0.0);
      expect(clamped.chroma, 0.0);
      expect(clamped.hue, isNull);
      expect(clamped.alpha, 1.0);

      expect(normalizedHue.hue, 5.0);
    });

    test('raw bypasses normalization', () {
      final raw = OklchColor.raw(-1.0, -2.0, 725.0, 2.0);

      expect(raw.lightness, -1.0);
      expect(raw.chroma, -2.0);
      expect(raw.hue, 725.0);
      expect(raw.alpha, 2.0);
    });

    test('copyWith / equality / hashCode', () {
      final color = OklchColor(0.6, 0.15, 25.0, 0.8);
      final updated = color.copyWith(chroma: 0.2, hue: null);

      expect(updated, OklchColor(0.6, 0.2, null, 0.8));
      expect(
        OklchColor(0.2, 0.1, null, 1.0).hashCode,
        OklchColor(0.2, 0.1, null, 1.0).hashCode,
      );
    });

    test('copyWith accepts numeric hue values', () {
      final color = OklchColor(0.6, 0.15, 25.0, 0.8);
      final updated = color.copyWith(hue: 42);

      expect(updated.hue, 42.0);
    });
  });

  group('conversion', () {
    test('toOklab / from Oklab round-trip', () {
      final source = OklchColor(0.65, 0.2, 42.0, 0.7);
      final roundTrip = source.toOklab().toOklch();

      expect(roundTrip.lightness, closeTo(source.lightness, 1e-12));
      expect(roundTrip.chroma, closeTo(source.chroma, 1e-12));
      expect(roundTrip.hue, closeTo(source.hue!, 1e-12));
      expect(roundTrip.alpha, source.alpha);
    });
  });

  group('lerp', () {
    test('shortest-path hue wrapping', () {
      final start = OklchColor(0.5, 0.2, 350.0);
      final end = OklchColor(0.5, 0.2, 10.0);
      final mid = start.lerp(end, 0.5);

      expect(mid.hue, closeTo(0.0, 1e-12));
    });

    test('missing hue carries forward', () {
      final start = OklchColor(0.5, 0.2, null);
      final end = OklchColor(0.8, 0.4, 80.0);
      final mid = start.lerp(end, 0.5);

      expect(mid.hue, 80.0);
    });

    test('preserves endpoints when one hue is missing', () {
      final start = OklchColor(0.5, 0.2, null, 0.7);
      final end = OklchColor(0.8, 0.4, 80.0, 0.9);

      expect(start.lerp(end, 0.0), start);
      expect(start.lerp(end, 1.0), end);
      expect(end.lerp(start, 0.0), end);
      expect(end.lerp(start, 1.0), start);
    });

    test('both missing hues stay missing', () {
      final start = OklchColor(0.4, 0.0, null);
      final end = OklchColor(0.8, 0.0, null);
      final mid = start.lerp(end, 0.5);

      expect(mid.hue, isNull);
    });
  });
}
