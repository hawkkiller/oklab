# Flutter Oklab Integration Plan

## Context

`packages/oklab` provides core Oklab/Oklch math in pure Dart. Flutter integration should stay in a separate package so the core library remains Flutter-free and reusable in server/CLI projects.

This plan introduces `packages/oklab_flutter` with `dart:ui` `Color` interop.

## Goals

1. Add a Flutter package that depends on `oklab`.
2. Provide ergonomic conversion APIs between Flutter `Color` and `OklabColor`/`OklchColor`.
3. Preserve alpha and keep conversion behavior consistent with `oklab` package rules.
4. Ship with tests, docs, and examples that validate expected behavior.

## Non-Goals (Initial Version)

1. Parsing/serializing CSS color strings.
2. Gamut mapping strategies beyond current channel clipping behavior.
3. Flutter widgets/themes built on top of Oklab (can be follow-up work).

## Proposed Package Layout

```text
packages/
  oklab/
  oklab_flutter/
    lib/
      oklab_flutter.dart
      src/color_extensions.dart
      src/color_factories.dart
    test/
      color_extensions_test.dart
      color_factories_test.dart
    example/
      lib/main.dart
    pubspec.yaml
    README.md
    CHANGELOG.md
```

## API Proposal

### `Color` extensions

- `OklabColor toOklab()`
- `OklchColor toOklch()`

### Factory helpers

Use extension static methods or top-level helpers (pick one style and keep it consistent):

- `Color fromOklab(OklabColor color)`
- `Color fromOklch(OklchColor color)`

### Alpha behavior

- `Color.a`/`opacity` maps to `OklabColor.alpha`/`OklchColor.alpha` in `0..1`.
- Round-trip should preserve alpha within floating-point tolerance.

## Implementation Phases

### 1. Create `oklab_flutter` package

1. Scaffold Flutter package under `packages/oklab_flutter`.
2. Add dependency on local `oklab` package.
3. Set SDK constraints compatible with the repo toolchain.
4. Export only public entrypoint from `lib/oklab_flutter.dart`.

### 2. Implement conversion layer

1. `Color -> OklabColor`:
   - Read 8-bit RGBA from Flutter `Color`.
   - Delegate conversion math to `OklabColor.fromRgb`.
2. `Color -> OklchColor`:
   - Convert through Oklab (`toOklab().toOklch()`) to keep one math path.
3. `OklabColor/OklchColor -> Color`:
   - Use `toRgb()` tuple from `oklab` and construct Flutter `Color` with clamped channels.

### 3. Testing

1. Unit tests for extension methods and factory helpers.
2. Round-trip tests:
   - `Color -> Oklab -> Color`
   - `Color -> Oklch -> Color`
3. Edge cases:
   - transparent colors (`alpha = 0`)
   - grayscale/achromatic colors (null hue behavior via Oklch)
   - boundary values (`0`, `255`, and mid-tones)

### 4. Example and docs

1. Add minimal Flutter app example showing:
   - converting `Color` to Oklab/Oklch
   - generating a small perceptual gradient and converting back to `Color`
2. Document API and caveats in `README.md`.
3. Add changelog entry for initial integration release.

### 5. Verification and CI

1. Run `flutter test` in `packages/oklab_flutter`.
2. Ensure existing `packages/oklab` tests still pass.
3. Add/extend workspace CI to run both package test suites.

## Acceptance Criteria

1. `oklab_flutter` package is present and builds.
2. Public API covers both conversion directions (`Color <-> Oklab/Oklch`).
3. Tests validate round-trips and edge cases with passing results.
4. Example compiles and demonstrates real integration usage.
5. Documentation explains installation and core conversion APIs.

## Suggested Rollout Order

1. Package scaffolding + dependency wiring.
2. Core extension/factory APIs.
3. Tests.
4. Example app.
5. README/CHANGELOG + CI updates.
