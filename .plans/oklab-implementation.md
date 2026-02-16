# Oklab Color Space Implementation Plan

## Context

Implement the core Oklab/Oklch color space library for Dart. The Oklab color space (by Björn Ottosson) is a perceptually uniform color space — an improvement over CIELAB for tasks like color interpolation, palette generation, and accessibility. Oklch is its cylindrical (polar) form, more intuitive for hue-based operations.

This plan covers the `packages/oklab` package only. The optional `packages/oklab_flutter` package is out of scope for now.

Target behavior is aligned with browser/CSS semantics where practical (CSS Color 4), not just raw math conversion.

## Reference

- [Oklab blog post — Björn Ottosson](https://bottosson.github.io/posts/oklab/) (matrices, conversion algorithm)
- [CSS Color Level 4 §9.2](https://www.w3.org/TR/css-color-4/#ok-lab) (formal Oklab + Oklch definition)
- [CSS Color Level 4 Editor's Draft](https://drafts.csswg.org/css-color-4/) (latest behavior details, parsing/clamping, conversion sample code)
- [WPT css-color tests](https://wpt.fyi/results/css/css-color) (cross-browser expected behavior)
- Oklch is simply the polar/cylindrical form of Oklab (C = √(a²+b²), h = atan2(b,a)). No separate spec — defined in both sources above.

## Design Decisions

- **Immutable final classes** with `final` fields, `copyWith`, `==`/`hashCode`
- **Alpha channel included** on all types (defaults to `1.0`)
- **Core scope**: types, conversions, lerp — no unrelated manipulation utilities yet
- **Dart API naming**: use lowerCamelCase, descriptive field names (`lightness`, `chroma`, `hue`) instead of uppercase channel symbols in public API.
- **Constructor style (idiomatic Dart)**:
  - Public constructors are `factory` constructors that normalize values.
  - Optional private `const` raw constructors can be used internally when values are already normalized.
- **Browser-compatible normalization at construction time (CSS-like parsed value behavior)**:
  - Oklab `lightness` clamped to `[0, 1]`
  - Oklch `lightness` clamped to `[0, 1]`
  - Oklch `chroma` clamped to `>= 0`
  - Oklch `hue` normalized to `[0, 360)` when finite
  - `alpha` clamped to `[0, 1]`
- **Achromatic hue handling (CSS-like powerless hue behavior)**:
  - Use `epsilon = 0.000004` for OkLCh hue powerlessness
  - In Dart, represent missing hue as `null` (`double? hue`) to mirror CSS `none` semantics.
  - `oklab -> oklch`: if `chroma <= epsilon`, set `hue = null`
  - `oklch -> oklab`: if `hue == null`, treat color as achromatic (`a = 0`, `b = 0`)
- **Extended-range transfer functions**: sRGB companding supports negative values by sign-reflection (matching CSS sample conversion code), and values are not clamped during intermediate conversion stages.
- **RGB projection policy**:
  - `toRgb()` is an explicit 8-bit projection API (not CSS text serialization).
  - Project to displayable sRGB by clipping each channel to `[0,1]`.
  - Quantize with `round(clamp01(channel) * 255)` to produce `0..255` ints.
- **Equality semantics with missing hue**:
  - Missing hue uses `null`, so standard Dart equality/hash behavior is sufficient.

## File Structure

```
packages/oklab/
├── lib/
│   ├── oklab.dart                    # Public barrel export
│   └── src/
│       ├── oklab_color.dart          # OklabColor class
│       ├── oklch_color.dart          # OklchColor class
│       ├── conversions.dart          # All conversion functions
│       └── math_utils.dart           # sRGB transfer functions, clamp, etc.
└── test/
    ├── oklab_color_test.dart         # OklabColor unit tests
    ├── oklch_color_test.dart         # OklchColor unit tests
    ├── conversions_test.dart         # Conversion round-trip & reference tests
    └── math_utils_test.dart          # Transfer function tests
```

Delete `lib/src/oklab_base.dart` and `test/oklab_test.dart` (scaffolded placeholders).

---

## Step 1: `math_utils.dart` — Low-level math helpers

Conversion building blocks used by the conversion functions.

```dart
/// Linearize an sRGB component (extended range allowed) -> linear.
/// Inverse of the sRGB companding/gamma function.
double srgbToLinear(double c);

/// Apply sRGB gamma to a linear component (extended range allowed) -> sRGB.
double linearToSrgb(double c);

/// Clamp a double to [0, 1].
double clamp01(double v);
```

The sRGB transfer function (IEC 61966-2-1), with CSS-style extended-range support:
- Linear → sRGB:
  - `abs(c) <= 0.0031308 ? 12.92 * c : sign(c) * (1.055 * pow(abs(c), 1/2.4) - 0.055)`
- sRGB → Linear:
  - `abs(c) <= 0.04045 ? c / 12.92 : sign(c) * pow((abs(c) + 0.055) / 1.055, 2.4)`

---

Add helper utilities in the same file:
- `const double kOklchHueEpsilon = 0.000004`
- `double normalizeHueDegrees(double hue)` -> normalize finite hue to `[0, 360)`
- `bool isPowerlessOklchHue(double chroma)` -> `chroma <= kOklchHueEpsilon`

---

## Step 2: `oklab_color.dart` — OklabColor class

```dart
final class OklabColor {
  final double lightness;  // Clamped to 0..1
  final double a;  // Green–red axis: ~-0.4..0.4
  final double b;  // Blue–yellow axis: ~-0.4..0.4
  final double alpha; // Opacity: clamped to 0..1, default 1.0

  factory OklabColor(double lightness, double a, double b, [double alpha = 1.0]);
  const OklabColor._raw(this.lightness, this.a, this.b, this.alpha);

  /// Create from sRGB 0–255 integer values.
  factory OklabColor.fromRgb(int r, int g, int b, [double alpha = 1.0]);

  /// Convert to Oklch.
  OklchColor toOklch();

  /// Convert back to displayable sRGB as (r, g, b, a) with 0–255 ints.
  /// Clip channels to gamut [0,1] before 8-bit quantization.
  (int r, int g, int b, double alpha) toRgb();

  /// Linear interpolation between two Oklab colors.
  OklabColor lerp(OklabColor other, double t);

  /// Copy with optional overrides.
  OklabColor copyWith({double? lightness, double? a, double? b, double? alpha});

  @override bool operator ==(Object other);
  @override int get hashCode;
  @override String toString(); // "OklabColor(lightness: 0.63, a: 0.23, b: 0.13, alpha: 1.0)"
}
```

Constructor behavior:
- `lightness` and `alpha` are clamped to match CSS parsed-value normalization.
- `a` and `b` are unbounded.
- `fromRgb(r, g, b)` clamps input integers to `0..255` before conversion (CSS-like parsed-value behavior).

---

## Step 3: `oklch_color.dart` — OklchColor class

```dart
final class OklchColor {
  final double lightness;  // Clamped to 0..1
  final double chroma;  // Clamped to >= 0
  final double? hue;  // Degrees normalized to [0,360), or null for missing hue
  final double alpha; // Opacity: clamped to 0..1

  factory OklchColor(double lightness, double chroma, double? hue, [double alpha = 1.0]);
  const OklchColor._raw(this.lightness, this.chroma, this.hue, this.alpha);

  /// Convert to Oklab.
  OklabColor toOklab();

  /// Convert to sRGB.
  (int r, int g, int b, double alpha) toRgb();

  /// Linear interpolation with shortest-path hue interpolation.
  OklchColor lerp(OklchColor other, double t);

  /// Copy with optional overrides.
  OklchColor copyWith({double? lightness, double? chroma, double? hue, double? alpha});

  @override bool operator ==(Object other);
  @override int get hashCode;
  @override String toString();
}
```

Hue lerp uses shortest-arc interpolation (handles the 350°→10° wrap-around).
For browser-style achromatic behavior:
- If one side has missing hue (`null`), carry forward the other hue.
- If both sides are missing hue, keep result hue as `null`.

Constructor behavior:
- `lightness` and `alpha` are clamped to `[0, 1]`.
- `chroma` is clamped to `>= 0`.
- `hue` is normalized to `[0, 360)` when non-null.
- If `chroma <= kOklchHueEpsilon`, canonicalize to `hue = null`.

---

## Step 4: `conversions.dart` — Conversion functions

The core math. These are the free functions that the classes delegate to.

```dart
/// Linear sRGB (0..1 per channel) -> Oklab.
({double lightness, double a, double b}) linearSrgbToOklab(double r, double g, double b);

/// Oklab -> Linear sRGB (0..1 per channel).
({double r, double g, double b}) oklabToLinearSrgb(double lightness, double a, double b);

/// Oklab -> Oklch.
/// If chroma <= epsilon, hue is null ("missing hue").
({double lightness, double chroma, double? hue}) oklabToOklch(double lightness, double a, double b);

/// Oklch -> Oklab.
/// If hue is null ("missing hue"), returns a = 0, b = 0.
({double lightness, double a, double b}) oklchToOklab(double lightness, double chroma, double? hue);
```

**Oklab ↔ Linear sRGB matrices** (from Björn Ottosson's reference):

```
Linear sRGB → LMS (M1):
 0.4122214708  0.5363325363  0.0514459929
 0.2119034982  0.6806995451  0.1073969566
 0.0883024619  0.2817188376  0.6299787005

LMS^(1/3) → Lab (M2):
 0.2104542553  0.7936177850 -0.0040720468
 1.9779984951 -2.4285922050  0.4505937099
 0.0259040371  0.7827717662 -0.8086757660
```

And the inverse matrices for the reverse direction.

Use the CSS sample-code epsilon for OkLCh hue powerlessness:
- `epsilon = kOklchHueEpsilon`

---

## Step 5: `oklab.dart` — Barrel export

```dart
library oklab;

export 'src/oklab_color.dart';
export 'src/oklch_color.dart';
```

Only export the color classes. Conversions and math utils are internal implementation details.

---

## Step 6: Tests

### `conversions_test.dart`
- **Known reference values**: Black, white, primaries, and selected mid-tones against CSS/WPT-compatible expected values (with tolerances)
- **Round-trip accuracy**: sRGB → Oklab → sRGB should match within ±1/255 per channel
- **Edge cases**: Out-of-gamut values, zero chroma, near-zero chroma around epsilon (`0.000004`)
- **Powerless hue**: verify `oklabToOklch` emits `hue = null` for achromatic colors

### `oklab_color_test.dart`
- Construction, `copyWith`, `==`, `hashCode`
- Constructor normalization (`lightness`, `alpha` clamping)
- `fromRgb` factory: red, green, blue, white, black
- `toRgb()` round-trip
- `lerp` at t=0, t=1, t=0.5

### `oklch_color_test.dart`
- Construction, `copyWith`, `==`, `hashCode`
- Constructor normalization (`lightness`, `chroma`, `hue`, `alpha`)
- `toOklab()` / from Oklab round-trip
- `lerp` with hue wrapping (e.g., 350° → 10° should go through 0°)
- `lerp` with missing hue (`null`) should follow carry-forward behavior

### `math_utils_test.dart`
- sRGB transfer function: known values (0, 0.5, 1.0), negative extended-range values, and round-trip
- Hue normalization and powerless-hue epsilon helper tests

---

## Verification

```bash
cd packages/oklab && dart test
```

All tests should pass. Key things to verify manually:
- `OklabColor.fromRgb(255, 0, 0).lightness` should be approximately `0.6279`
- `OklabColor.fromRgb(0, 0, 0)` → `lightness ≈ 0, a ≈ 0, b ≈ 0`
- `OklabColor.fromRgb(255, 255, 255)` → `lightness ≈ 1, a ≈ 0, b ≈ 0`
- Round-trip: any sRGB → Oklab → sRGB should match within ±1 per 0–255 channel
- Achromatic conversion: near-neutral colors should produce `Oklch.hue = null` when `chroma <= 0.000004`
- Hue normalization: inputs like `-30`, `360`, `725` normalize to `330`, `0`, `5`

## Implementation Order

1. `math_utils.dart` (no dependencies)
2. `conversions.dart` (depends on math_utils)
3. `oklab_color.dart` (depends on conversions)
4. `oklch_color.dart` (depends on conversions, oklab_color)
5. `oklab.dart` barrel export
6. Delete old scaffold files
7. Tests (all test files)
8. Run `dart test` and verify
