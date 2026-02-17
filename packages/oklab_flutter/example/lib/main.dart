import 'package:flutter/material.dart';
import 'package:oklab_flutter/oklab_flutter.dart';

void main() {
  runApp(const _ComparisonApp());
}

class _ComparisonApp extends StatelessWidget {
  const _ComparisonApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF6F5F9),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _ComparisonCard(
                  title: 'HSL vs OKLCH',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionLabel('HSL'),
                      SizedBox(height: 12),
                      _HueGradientBar(colorAtHue: _hslColorAtHue),
                      SizedBox(height: 20),
                      _SectionLabel('OKLCH'),
                      SizedBox(height: 12),
                      _HueGradientBar(colorAtHue: _oklchColorAtHue),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _LinearGradientComparisonCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ComparisonCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEAF0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1C2B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1D1C2B),
      ),
    );
  }
}

class _LinearGradientComparisonCard extends StatelessWidget {
  const _LinearGradientComparisonCard();

  @override
  Widget build(BuildContext context) {
    const start = Color(0xFF0000FF);
    const end = Color(0xFFFFFF00);

    final linearGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [start, end],
    );
    final oklabGradient = oklabLinearGradient(
      colors: [start.toOklab(), end.toOklab()],
      samplesPerSegment: 24,
    );

    return _ComparisonCard(
      title: 'LinearGradient vs OklabLinearGradient',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('LinearGradient (sRGB interpolation)'),
          const SizedBox(height: 12),
          _GradientPreviewBar(gradient: linearGradient),
          const SizedBox(height: 20),
          const _SectionLabel('oklabLinearGradient (perceptual interpolation)'),
          const SizedBox(height: 12),
          _GradientPreviewBar(gradient: oklabGradient),
        ],
      ),
    );
  }
}

class _GradientPreviewBar extends StatelessWidget {
  final Gradient gradient;

  const _GradientPreviewBar({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const SizedBox(height: 56),
    );
  }
}

class _HueGradientBar extends StatelessWidget {
  final Color Function(double hue) colorAtHue;

  const _HueGradientBar({required this.colorAtHue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: CustomPaint(
        painter: _HueGradientPainter(colorAtHue),
      ),
    );
  }
}

class _HueGradientPainter extends CustomPainter {
  final Color Function(double hue) colorAtHue;

  _HueGradientPainter(this.colorAtHue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    canvas.save();
    canvas.clipRRect(rrect);

    final paint = Paint();
    final width = size.width.round().clamp(1, 1 << 20);

    for (var x = 0; x < width; x++) {
      final t = width == 1 ? 0.0 : x / (width - 1);
      paint.color = colorAtHue(360.0 * t);
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), 0, 1, size.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HueGradientPainter oldDelegate) {
    return false;
  }
}

Color _hslColorAtHue(double hue) {
  return HSLColor.fromAHSL(1.0, hue, 1.0, 0.56).toColor();
}

Color _oklchColorAtHue(double hue) {
  return colorFromOklch(
    OklchColor(
      0.78,
      0.14,
      hue,
    ),
  );
}
