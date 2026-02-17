# oklab_flutter

Flutter helpers for converting between Flutter `Color` and `oklab` color types.

## Features

- `Color` -> `OklabColor` / `OklchColor`
- `OklabColor` / `OklchColor` -> `Color`
- Extension methods and top-level factory helpers

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:oklab/oklab.dart';
import 'package:oklab_flutter/oklab_flutter.dart';

final source = const Color(0xFF40A0D0);
final oklab = source.toOklab();
final oklch = source.toOklch();

final mid = oklab.lerp(OklabColor.fromRgb(255, 140, 0), 0.5);
final asColor = mid.toColor();
final fromLch = colorFromOklch(oklch.copyWith(chroma: oklch.chroma * 0.9));
```
