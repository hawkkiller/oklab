# oklab

Perceptual color types and conversions for the Oklab/Oklch color spaces in Dart.

## Features

- `OklabColor` and `OklchColor` value types
- RGB <-> Oklab <-> Oklch conversion
- Alpha-preserving interpolation and copy helpers
- Input normalization for safe construction

## Usage

```dart
import 'package:oklab/oklab.dart';

final oklab = OklabColor.fromRgb(64, 160, 208);
final oklch = oklab.toOklch();

final adjusted = oklch.copyWith(
  lightness: 0.72,
  chroma: oklch.chroma * 0.8,
);

final (r, g, b, a) = adjusted.toRgb();
```

## Related package

Use `oklab_flutter` for Flutter `Color` interop.
