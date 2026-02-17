import 'package:oklab/oklab.dart';
import 'package:test/test.dart';

void main() {
  group('construction and value semantics', () {
    test('normalizes constructor inputs', () {
      final color = OklabColor(-1.0, double.nan, double.infinity, 2.0);

      expect(color.lightness, 0.0);
      expect(color.a, 0.0);
      expect(color.b, 0.0);
      expect(color.alpha, 1.0);
    });

    test('raw bypasses normalization', () {
      final raw = OklabColor.raw(-1.0, double.nan, double.infinity, 2.0);

      expect(raw.lightness, -1.0);
      expect(raw.a.isNaN, isTrue);
      expect(raw.b, double.infinity);
      expect(raw.alpha, 2.0);
    });

    test('copyWith / equality / hashCode', () {
      final color = OklabColor(0.5, 0.1, -0.2, 0.8);
      final updated = color.copyWith(lightness: 0.75);

      expect(updated, OklabColor(0.75, 0.1, -0.2, 0.8));
      expect(
        OklabColor(0.1, 0.2, 0.3, 1.0).hashCode,
        OklabColor(0.1, 0.2, 0.3, 1.0).hashCode,
      );
    });
  });

  group('rgb conversion', () {
    test('fromRgb reference values', () {
      final red = OklabColor.fromRgb(255, 0, 0);
      final black = OklabColor.fromRgb(0, 0, 0);
      final white = OklabColor.fromRgb(255, 255, 255);

      expect(red.lightness, closeTo(0.6279553606146, 1e-12));
      expect(black.lightness, closeTo(0.0, 1e-12));
      expect(white.lightness, closeTo(1.0, 1e-8));
    });

    test('toRgb round-trip within +/-1', () {
      const samples = <(int, int, int)>[
        (255, 0, 0),
        (0, 255, 0),
        (0, 0, 255),
        (255, 255, 255),
        (12, 34, 56),
      ];

      for (final (r, g, b) in samples) {
        final color = OklabColor.fromRgb(r, g, b);
        final (rr, gg, bb, _) = color.toRgb();

        expect((rr - r).abs(), lessThanOrEqualTo(1));
        expect((gg - g).abs(), lessThanOrEqualTo(1));
        expect((bb - b).abs(), lessThanOrEqualTo(1));
      }
    });
  });

  group('operations', () {
    test('toOklch round-trip', () {
      final source = OklabColor.fromRgb(120, 200, 80, 0.7);
      final lab = source.toOklch().toOklab();

      expect(lab.lightness, closeTo(source.lightness, 1e-12));
      expect(lab.a, closeTo(source.a, 1e-12));
      expect(lab.b, closeTo(source.b, 1e-12));
      expect(lab.alpha, source.alpha);
    });

    test('lerp', () {
      final a = OklabColor(0.2, -0.1, 0.3, 0.4);
      final b = OklabColor(0.8, 0.3, -0.1, 1.0);

      expect(a.lerp(b, 0.0), a);
      final atEnd = a.lerp(b, 1.0);
      expect(atEnd.lightness, closeTo(b.lightness, 1e-12));
      expect(atEnd.a, closeTo(b.a, 1e-12));
      expect(atEnd.b, closeTo(b.b, 1e-12));
      expect(atEnd.alpha, closeTo(b.alpha, 1e-12));

      final mid = a.lerp(b, 0.5);
      expect(mid.lightness, closeTo(0.5, 1e-12));
      expect(mid.a, closeTo(0.1, 1e-12));
      expect(mid.b, closeTo(0.1, 1e-12));
      expect(mid.alpha, closeTo(0.7, 1e-12));
    });
  });
}
