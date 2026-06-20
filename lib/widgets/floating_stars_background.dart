import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

/// Magical learning backdrop — subtle but visible decorative layers.
/// Opacity capped at 10%; uses full budget so elements read on light screens.
class FloatingStarsBackground extends StatefulWidget {
  const FloatingStarsBackground({super.key});

  @override
  State<FloatingStarsBackground> createState() =>
      _FloatingStarsBackgroundState();
}

class _FloatingStarsBackgroundState extends State<FloatingStarsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MagicalBackgroundPainter(
                    progress: _controller.value,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MagicalBackgroundPainter extends CustomPainter {
  _MagicalBackgroundPainter({required this.progress});

  final double progress;

  /// Hard cap — decorative only, never louder than this.
  static const double _maxOpacity = 0.10;

  static const List<_ParallaxBlob> _blobs = [
    _ParallaxBlob(0.78, 0.08, 90, 0.30, 0.0, AppStyles.primary),
    _ParallaxBlob(0.14, 0.22, 70, 0.25, 1.2, AppStyles.secondary),
    _ParallaxBlob(0.88, 0.38, 80, 0.28, 2.4, AppStyles.primary),
    _ParallaxBlob(0.06, 0.55, 75, 0.22, 3.6, AppStyles.secondary),
    _ParallaxBlob(0.72, 0.68, 65, 0.26, 4.8, AppStyles.primary),
    _ParallaxBlob(0.35, 0.82, 55, 0.20, 5.5, AppStyles.secondary),
    _ParallaxBlob(0.50, 0.45, 100, 0.18, 6.2, AppStyles.primary),
  ];

  static const List<_ParallaxStar> _stars = [
    _ParallaxStar(0.12, 0.10, 7, 0.50, 0.2),
    _ParallaxStar(0.30, 0.18, 6, 0.55, 0.9),
    _ParallaxStar(0.55, 0.12, 7, 0.48, 1.6),
    _ParallaxStar(0.82, 0.20, 6, 0.52, 2.3),
    _ParallaxStar(0.92, 0.35, 7, 0.50, 3.1),
    _ParallaxStar(0.08, 0.48, 6, 0.54, 3.8),
    _ParallaxStar(0.25, 0.62, 7, 0.49, 4.5),
    _ParallaxStar(0.68, 0.58, 6, 0.53, 5.2),
    _ParallaxStar(0.45, 0.72, 7, 0.51, 5.9),
    _ParallaxStar(0.88, 0.78, 6, 0.47, 6.6),
    _ParallaxStar(0.18, 0.85, 7, 0.50, 7.3),
    _ParallaxStar(0.58, 0.88, 6, 0.48, 8.0),
  ];

  static const List<_ParallaxSparkle> _sparkles = [
    _ParallaxSparkle(0.20, 0.28, 0.82, 0.1),
    _ParallaxSparkle(0.42, 0.40, 0.88, 0.6),
    _ParallaxSparkle(0.65, 0.25, 0.85, 1.2),
    _ParallaxSparkle(0.80, 0.50, 0.90, 1.8),
    _ParallaxSparkle(0.32, 0.52, 0.84, 2.4),
    _ParallaxSparkle(0.58, 0.65, 0.87, 3.0),
    _ParallaxSparkle(0.15, 0.70, 0.86, 3.6),
    _ParallaxSparkle(0.95, 0.62, 0.91, 4.2),
    _ParallaxSparkle(0.48, 0.32, 0.83, 4.8),
    _ParallaxSparkle(0.72, 0.82, 0.89, 5.4),
    _ParallaxSparkle(0.38, 0.15, 0.84, 6.0),
    _ParallaxSparkle(0.60, 0.45, 0.88, 6.6),
    _ParallaxSparkle(0.10, 0.32, 0.86, 7.2),
    _ParallaxSparkle(0.85, 0.88, 0.90, 7.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    _drawAmbientWash(canvas, size);

    for (final _ParallaxBlob blob in _blobs) {
      _drawBlob(canvas, size, blob);
    }
    for (final _ParallaxStar star in _stars) {
      _drawStar(canvas, size, star);
    }
    for (final _ParallaxSparkle sparkle in _sparkles) {
      _drawSparkle(canvas, size, sparkle);
    }
  }

  void _drawAmbientWash(Canvas canvas, Size size) {
    final Paint topWash = Paint()
      ..shader = RadialGradient(
        colors: [
          AppStyles.primary.withValues(alpha: _clampOpacity(0.08)),
          AppStyles.primary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.15),
        radius: size.width * 0.45,
      ));
    canvas.drawRect(Offset.zero & size, topWash);

    final Paint bottomWash = Paint()
      ..shader = RadialGradient(
        colors: [
          AppStyles.secondary.withValues(alpha: _clampOpacity(0.07)),
          AppStyles.secondary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.85),
        radius: size.width * 0.4,
      ));
    canvas.drawRect(Offset.zero & size, bottomWash);
  }

  Offset _parallaxOffset(
    Size size,
    double depth,
    double phase,
    double amplitude,
  ) {
    final double t = progress * math.pi * 2;
    final double speed = 0.35 + depth * 0.65;
    return Offset(
      math.sin(t * speed + phase) * amplitude * (0.5 + depth * 0.5),
      math.cos(t * speed * 0.75 + phase * 1.3) *
          amplitude *
          0.85 *
          (0.5 + depth * 0.5),
    );
  }

  void _drawBlob(Canvas canvas, Size size, _ParallaxBlob blob) {
    final Offset drift = _parallaxOffset(size, blob.depth, blob.phase, 12);
    final Offset center = Offset(
      blob.x * size.width + drift.dx,
      blob.y * size.height + drift.dy,
    );

    final Paint outer = Paint()
      ..color = blob.color.withValues(alpha: _clampOpacity(0.09))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, blob.radius, outer);

    final Paint mid = Paint()
      ..color = blob.color.withValues(alpha: _clampOpacity(0.06));
    canvas.drawCircle(center, blob.radius * 0.65, mid);
  }

  void _drawStar(Canvas canvas, Size size, _ParallaxStar star) {
    final Offset drift = _parallaxOffset(size, star.depth, star.phase, 16);
    final Offset center = Offset(
      star.x * size.width + drift.dx,
      star.y * size.height + drift.dy,
    );
    final double twinkle =
        0.65 + 0.35 * math.sin((progress + star.phase) * math.pi * 2);
    final double opacity = _clampOpacity(0.09 * twinkle);

    _drawFourPointStar(canvas, center, star.size, opacity);
  }

  void _drawSparkle(Canvas canvas, Size size, _ParallaxSparkle sparkle) {
    final Offset drift = _parallaxOffset(size, sparkle.depth, sparkle.phase, 20);
    final Offset center = Offset(
      sparkle.x * size.width + drift.dx,
      sparkle.y * size.height + drift.dy,
    );
    final double pulse =
        0.55 + 0.45 * math.sin((progress * 1.4 + sparkle.phase) * math.pi * 2);
    final double opacity = _clampOpacity(0.06 + pulse * 0.04);

    final Paint dot = Paint()
      ..color = AppStyles.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.2, dot);

    final Paint ray = Paint()
      ..color = AppStyles.secondary.withValues(alpha: opacity)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const double rayLen = 6;
    canvas.drawLine(
      Offset(center.dx - rayLen, center.dy),
      Offset(center.dx + rayLen, center.dy),
      ray,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - rayLen),
      Offset(center.dx, center.dy + rayLen),
      ray,
    );
  }

  void _drawFourPointStar(
    Canvas canvas,
    Offset center,
    double size,
    double opacity,
  ) {
    final Paint fill = Paint()
      ..color = AppStyles.secondary.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.32, fill);

    final Paint ray = Paint()
      ..color = AppStyles.primary.withValues(alpha: opacity)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2 + math.pi / 4;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * size,
          center.dy + math.sin(angle) * size,
        ),
        ray,
      );
    }
  }

  double _clampOpacity(double value) => value.clamp(0.0, _maxOpacity);

  @override
  bool shouldRepaint(covariant _MagicalBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ParallaxBlob {
  const _ParallaxBlob(
    this.x,
    this.y,
    this.radius,
    this.depth,
    this.phase,
    this.color,
  );

  final double x;
  final double y;
  final double radius;
  final double depth;
  final double phase;
  final Color color;
}

class _ParallaxStar {
  const _ParallaxStar(this.x, this.y, this.size, this.depth, this.phase);

  final double x;
  final double y;
  final double size;
  final double depth;
  final double phase;
}

class _ParallaxSparkle {
  const _ParallaxSparkle(this.x, this.y, this.depth, this.phase);

  final double x;
  final double y;
  final double depth;
  final double phase;
}
