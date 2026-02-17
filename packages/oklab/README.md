# oklab

Perceptual color types and conversions for the Oklab/Oklch color spaces in Dart.

## Features

- `OklabColor` and `OklchColor` value types
- RGB <-> Oklab <-> Oklch conversion
- Alpha-preserving interpolation and copy helpers
- Input normalization for safe construction
- Max in-gamut Oklch chroma search for a given lightness and hue
- Oklch gamut helpers (`isOklchInSrgbGamut`, `clampOklchChromaToSrgbGamut`)

## Usage

```dart
import 'package:oklab/oklab.dart';

final oklab = OklabColor.fromRgb(64, 160, 208);
final oklch = oklab.toOklch();

final adjusted = oklch.copyWith(
  lightness: 0.72,
  chroma: oklch.chroma * 0.8,
);

final maxChroma = maxOklchChroma(0.72, 280.0);
final safeChroma = clampOklchChromaToSrgbGamut(0.72, 0.3, 280.0);
final isSafe = isOklchInSrgbGamut(0.72, safeChroma, 280.0);
final safeAdjusted = adjusted.clampChromaToSrgbGamut();

final (r, g, b, a) = adjusted.toRgb();
```

## Related package

Use `oklab_flutter` for Flutter `Color` interop.
