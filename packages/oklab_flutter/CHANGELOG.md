## Unreleased

* Added `oklabLinearGradient` helper to build `LinearGradient` values
  from Oklab colors using sampled perceptual interpolation.

## 0.0.1

* Initial Flutter integration for Oklab:
  * `Color.toOklab()` and `Color.toOklch()` extensions.
  * `colorFromOklab` and `colorFromOklch` helpers.
  * `toColor()` extensions on `OklabColor` and `OklchColor`.
* Added tests for:
  * Reference conversion behavior (`Color` -> `OklabColor`)
  * Achromatic hue behavior in Oklch conversion
  * RGBA round-trips within 8-bit tolerance
