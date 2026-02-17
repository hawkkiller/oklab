import 'dart:math' as math;

const double kOklchHueEpsilon = 0.000004;

double srgbToLinear(double c) {
  if (c.isNaN) {
    return 0.0;
  }

  final absC = c.abs();
  if (absC <= 0.04045) {
    return c / 12.92;
  }

  return _sign(c) * math.pow((absC + 0.055) / 1.055, 2.4).toDouble();
}

double linearToSrgb(double c) {
  if (c.isNaN) {
    return 0.0;
  }

  final absC = c.abs();
  if (absC <= 0.0031308) {
    return 12.92 * c;
  }

  return _sign(c) * (1.055 * math.pow(absC, 1.0 / 2.4).toDouble() - 0.055);
}

double clamp01(double v) {
  if (v.isNaN) {
    return 0.0;
  }

  if (v <= 0.0) {
    return 0.0;
  }

  if (v >= 1.0) {
    return 1.0;
  }

  return v;
}

double normalizeHueDegrees(double hue) {
  if (!hue.isFinite) {
    return 0.0;
  }

  var normalized = hue % 360.0;
  if (normalized < 0.0) {
    normalized += 360.0;
  }
  if (normalized == 360.0) {
    return 0.0;
  }

  return normalized;
}

bool isPowerlessOklchHue(double chroma) {
  if (!chroma.isFinite) {
    return true;
  }

  return chroma <= kOklchHueEpsilon;
}

double cubeRootSigned(double value) {
  if (value == 0.0) {
    return 0.0;
  }

  return _sign(value) * math.pow(value.abs(), 1.0 / 3.0).toDouble();
}

double normalizeUnitInterval(double value) => clamp01(value);

double normalizeFiniteOrZero(double value) {
  if (!value.isFinite) {
    return 0.0;
  }

  return value;
}

double normalizeNonNegative(double value) {
  if (!value.isFinite) {
    return 0.0;
  }

  if (value < 0.0) {
    return 0.0;
  }

  return value;
}

double? normalizeOptionalHue(double? hue) {
  if (hue == null || !hue.isFinite) {
    return null;
  }

  return normalizeHueDegrees(hue);
}

int clampRgb8(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > 255) {
    return 255;
  }
  return value;
}

double _sign(double value) => value < 0.0 ? -1.0 : 1.0;
