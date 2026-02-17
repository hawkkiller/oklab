import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oklab_flutter/oklab_flutter.dart';

int _byteChannel(double channel) => (channel * 255.0).round().clamp(0, 255);

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

      expect((_byteChannel(restored.a) - _byteChannel(source.a)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.r) - _byteChannel(source.r)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.g) - _byteChannel(source.g)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.b) - _byteChannel(source.b)).abs(), lessThanOrEqualTo(1));
    });

    test('oklch conversion round-trips in-gamut Flutter colors', () {
      const source = Color(0xB72AA6C4);
      final restored = source.toOklch().toColor();

      expect((_byteChannel(restored.a) - _byteChannel(source.a)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.r) - _byteChannel(source.r)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.g) - _byteChannel(source.g)).abs(), lessThanOrEqualTo(1));
      expect((_byteChannel(restored.b) - _byteChannel(source.b)).abs(), lessThanOrEqualTo(1));
    });
  });

  group('Oklab gradients', () {
    test('oklabLinearGradient samples midpoint in Oklab space', () {
      final start = OklabColor.fromRgb(255, 0, 0);
      final end = OklabColor.fromRgb(0, 0, 255);

      final gradient = oklabLinearGradient(
        colors: [start, end],
        samplesPerSegment: 2,
      );

      expect(gradient.colors.length, equals(3));
      expect(gradient.stops, equals([0.0, 0.5, 1.0]));
      expect(gradient.colors[0], equals(colorFromOklab(start)));
      expect(gradient.colors[1], equals(colorFromOklab(start.lerp(end, 0.5))));
      expect(gradient.colors[2], equals(colorFromOklab(end)));
    });

    test('oklabLinearGradient forwards gradient options', () {
      final gradient = oklabLinearGradient(
        colors: [
          OklabColor.fromRgb(0, 0, 0),
          OklabColor.fromRgb(255, 255, 255),
        ],
        stops: [0.2, 0.8],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        tileMode: TileMode.mirror,
        samplesPerSegment: 1,
      );

      expect(gradient.begin, equals(Alignment.topLeft));
      expect(gradient.end, equals(Alignment.bottomRight));
      expect(gradient.tileMode, equals(TileMode.mirror));
      expect(gradient.stops, equals([0.2, 0.8]));
    });

    test('oklabLinearGradient validates input', () {
      final first = OklabColor.fromRgb(0, 0, 0);
      final second = OklabColor.fromRgb(255, 255, 255);

      expect(
        () => oklabLinearGradient(colors: [first]),
        throwsArgumentError,
      );
      expect(
        () => oklabLinearGradient(
          colors: [first, second],
          samplesPerSegment: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => oklabLinearGradient(
          colors: [first, second],
          stops: [0.0],
        ),
        throwsArgumentError,
      );
      expect(
        () => oklabLinearGradient(
          colors: [first, second],
          stops: [0.7, 0.6],
        ),
        throwsArgumentError,
      );
      expect(
        () => oklabLinearGradient(
          colors: [first, second],
          stops: [-0.1, 0.8],
        ),
        throwsArgumentError,
      );
    });
  });
}
