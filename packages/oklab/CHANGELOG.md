## 0.0.1

* Initial release with Oklab and Oklch support.
* Added immutable `OklabColor` and `OklchColor` models with normalization.
* Added conversions:
  * sRGB <-> Oklab
  * Oklab <-> Oklch
  * RGB tuple projection API via `toRgb()`
* Added hue handling behavior for achromatic colors (`hue = null` when powerless).
* Added interpolation APIs (`lerp`) and value helpers (`copyWith`, equality, hashCode).
* Added test coverage for conversion accuracy, round-trips, normalization, and edge cases.
