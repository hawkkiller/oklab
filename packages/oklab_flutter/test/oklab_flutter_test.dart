import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:oklab/oklab.dart';
import 'package:oklab_flutter/oklab_flutter.dart';

void main() {
  group('Color extensions', () {
    test('toOklab returns expected reference lightness for red', () {
      final oklab = const Color(0xFFFF0000).toOklab();

      expect(oklab.lightness, closeTo(0.6279553606145516, 1e-12));
      expect(oklab.alpha, closeTo(1.0, 1e-12));
    });

    test('toOklch reports missing hue for achromatic color', () {
      final oklch = const Color(0xFF808080).toOklch();

      expect(oklch.hue, isNull);
    });
  });

  group('Reverse conversion', () {
    test('colorFromOklab and extension toColor are equivalent', () {
      final oklab = OklabColor.fromRgb(12, 34, 56, 0.4);

      expect(colorFromOklab(oklab), equals(oklab.toColor()));
    });

    test('round-trip preserves RGBA within 8-bit precision', () {
      const source = Color(0x8040A0D0);
      final restored = source.toOklab().toColor();

      expect((restored.alpha - source.alpha).abs(), lessThanOrEqualTo(1));
      expect((restored.red - source.red).abs(), lessThanOrEqualTo(1));
      expect((restored.green - source.green).abs(), lessThanOrEqualTo(1));
      expect((restored.blue - source.blue).abs(), lessThanOrEqualTo(1));
    });

    test('oklch conversion round-trips in-gamut Flutter colors', () {
      const source = Color(0xB72AA6C4);
      final restored = source.toOklch().toColor();

      expect((restored.alpha - source.alpha).abs(), lessThanOrEqualTo(1));
      expect((restored.red - source.red).abs(), lessThanOrEqualTo(1));
      expect((restored.green - source.green).abs(), lessThanOrEqualTo(1));
      expect((restored.blue - source.blue).abs(), lessThanOrEqualTo(1));
    });
  });
}
