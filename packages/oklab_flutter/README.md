# oklab_flutter

Flutter interop for the `oklab` package.

## Features

- Convert Flutter `Color` to `OklabColor` and `OklchColor`
- Convert `OklabColor`/`OklchColor` back to Flutter `Color`
- Preserve alpha across conversions

## Usage

```dart
import 'package:oklab/oklab.dart';
import 'package:oklab_flutter/oklab_flutter.dart';

final source = const Color(0xFF40A0D0);
final oklab = source.toOklab();
final oklch = source.toOklch();

final fromLab = oklab.toColor();
final fromLch = colorFromOklch(oklch);
```
