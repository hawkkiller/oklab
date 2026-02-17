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
          child: Container(
            width: 640,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEAF0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'HSL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1C2B),
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 12),
                _HueGradientBar(colorAtHue: _hslColorAtHue),
                SizedBox(height: 24),
                Text(
                  'OKLCH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1C2B),
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 12),
                _HueGradientBar(colorAtHue: _oklchColorAtHue),
              ],
            ),
          ),
        ),
      ),
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
