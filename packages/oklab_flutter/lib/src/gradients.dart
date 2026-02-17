import 'package:flutter/material.dart';
import 'package:oklab/oklab.dart';

import 'color_factories.dart';

/// Creates a [LinearGradient] that approximates interpolation in Oklab space.
///
/// Flutter gradients blend in sRGB space. This helper samples Oklab interpolation
/// into multiple RGB stops, then builds a regular [LinearGradient].
///
/// [samplesPerSegment] controls approximation quality per input segment.
/// Higher values are smoother, lower values are cheaper.
LinearGradient oklabLinearGradient({
  required List<OklabColor> colors,
  List<double>? stops,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
  int samplesPerSegment = 12,
}) {
  if (colors.length < 2) {
    throw ArgumentError.value(colors, 'colors', 'Must contain at least 2 Oklab colors.');
  }
  if (samplesPerSegment < 1) {
    throw ArgumentError.value(
      samplesPerSegment,
      'samplesPerSegment',
      'Must be at least 1.',
    );
  }

  final resolvedStops = _resolveStops(colors.length, stops);
  final sampledColors = <Color>[colorFromOklab(colors.first)];
  final sampledStops = <double>[resolvedStops.first];

  for (var i = 0; i < colors.length - 1; i++) {
    final startColor = colors[i];
    final endColor = colors[i + 1];
    final startStop = resolvedStops[i];
    final endStop = resolvedStops[i + 1];

    if (endStop == startStop) {
      sampledColors.add(colorFromOklab(endColor));
      sampledStops.add(endStop);
      continue;
    }

    for (var sample = 1; sample <= samplesPerSegment; sample++) {
      final t = sample / samplesPerSegment;
      sampledColors.add(colorFromOklab(startColor.lerp(endColor, t)));
      sampledStops.add(_lerp(startStop, endStop, t));
    }
  }

  return LinearGradient(
    begin: begin,
    end: end,
    colors: sampledColors,
    stops: sampledStops,
    tileMode: tileMode,
    transform: transform,
  );
}

List<double> _resolveStops(int colorCount, List<double>? stops) {
  if (stops == null) {
    final divisor = colorCount - 1;
    return List<double>.generate(colorCount, (i) => i / divisor);
  }

  if (stops.length != colorCount) {
    throw ArgumentError.value(
      stops,
      'stops',
      'Must have the same length as colors.',
    );
  }

  var previous = -1.0;
  for (final stop in stops) {
    if (!stop.isFinite || stop < 0.0 || stop > 1.0) {
      throw ArgumentError.value(
        stops,
        'stops',
        'All stop values must be finite and between 0 and 1.',
      );
    }
    if (stop < previous) {
      throw ArgumentError.value(
        stops,
        'stops',
        'Stop values must be non-decreasing.',
      );
    }
    previous = stop;
  }

  return List<double>.from(stops);
}

double _lerp(double start, double end, double t) => start + (end - start) * t;
