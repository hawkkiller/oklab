library;

/// Flutter interop for converting between `Color` and Oklab/Oklch types.
///
/// This library re-exports `package:oklab/oklab.dart` and adds:
/// - extension methods on `Color`
/// - conversion helpers to create `Color` from Oklab/Oklch
export 'package:oklab/oklab.dart';

export 'src/color_extensions.dart';
export 'src/color_factories.dart';
export 'src/gradients.dart';
