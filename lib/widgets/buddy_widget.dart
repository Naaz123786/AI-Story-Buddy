import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

enum _BuddyExpression { neutral, happy, confused }

/// Cartoon AI learning buddy robot holding an open storybook.
/// Lightweight vector mascot — no image or Lottie assets.
class BuddyWidget extends StatefulWidget {
  const BuddyWidget({
    super.key,
    required this.isHappy,
    this.wrongAnswerTrigger = 0,
    this.isStoryFinished = false,
  });

  final bool isHappy;
  final int wrongAnswerTrigger;
  final bool isStoryFinished;

  @override
  State<BuddyWidget> createState() => _BuddyWidgetState();
}

class _BuddyWidgetState extends State<BuddyWidget>
    with TickerProviderStateMixin {
  static const Size _robotSize = Size(190, 200);

  late final AnimationController _floatController;
  late final AnimationController _breathController;
  late final AnimationController _blinkController;
  late final AnimationController _bookSwayController;
  late final AnimationController _sparkleController;
  late final AnimationController _burstController;
  late final AnimationController _happyBounceController;
  late final AnimationController _storyBounceController;

  late final Animation<double> _floatY;
  late final Animation<double> _breathScale;
  late final Animation<double> _blinkAmount;
  late final Animation<double> _bookSway;
  late final Animation<double> _happyScale;
  late final Animation<double> _happyJump;
  late final Animation<double> _storyJump;
  late final Animation<double> _storyScale;

  Timer? _blinkTimer;
  Timer? _confusedTimer;
  bool _wasHappy = false;
  bool _isConfused = false;
  bool _wasStoryFinished = false;
  int _lastWrongTrigger = 0;

  _BuddyExpression get _expression {
    if (widget.isHappy) {
      return _BuddyExpression.happy;
    }
    if (_isConfused) {
      return _BuddyExpression.confused;
    }
    return _BuddyExpression.neutral;
  }

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _breathScale = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _blinkAmount = Tween<double>(begin: 1, end: 0.06).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeIn),
    );

    _bookSwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _bookSway = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _bookSwayController, curve: Curves.easeInOut),
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _happyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _happyScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.05)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_happyBounceController);
    _happyJump = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -20)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -20, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_happyBounceController);

    _storyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _storyJump = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -14)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -14, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
    ]).animate(_storyBounceController);
    _storyScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
    ]).animate(_storyBounceController);

    _lastWrongTrigger = widget.wrongAnswerTrigger;
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    final int delayMs = 4000 + math.Random().nextInt(2000);
    _blinkTimer = Timer(Duration(milliseconds: delayMs), _runBlink);
  }

  Future<void> _runBlink() async {
    if (!mounted) {
      return;
    }
    await _blinkController.forward();
    if (mounted) {
      await _blinkController.reverse();
    }
    if (mounted) {
      _scheduleNextBlink();
    }
  }

  void _handleWrongAnswer(int trigger) {
    if (trigger <= _lastWrongTrigger || widget.isHappy) {
      return;
    }
    _lastWrongTrigger = trigger;
    _triggerConfused();
  }

  void _triggerConfused() {
    _confusedTimer?.cancel();
    setState(() => _isConfused = true);
    _confusedTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isConfused = false);
      }
    });
  }

  @override
  void didUpdateWidget(BuddyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.wrongAnswerTrigger > oldWidget.wrongAnswerTrigger &&
        !widget.isHappy) {
      _handleWrongAnswer(widget.wrongAnswerTrigger);
    } else if (widget.wrongAnswerTrigger < _lastWrongTrigger) {
      _lastWrongTrigger = widget.wrongAnswerTrigger;
    }

    if (!widget.isStoryFinished) {
      _wasStoryFinished = false;
    } else if (!_wasStoryFinished) {
      _storyBounceController.forward(from: 0);
      _wasStoryFinished = true;
    }

    if (widget.isHappy && !_wasHappy) {
      _wasHappy = true;
      _confusedTimer?.cancel();
      _isConfused = false;
      _burstController.forward(from: 0);
      _happyBounceController.forward(from: 0);
    } else if (!widget.isHappy) {
      _wasHappy = false;
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _confusedTimer?.cancel();
    _floatController.dispose();
    _breathController.dispose();
    _blinkController.dispose();
    _bookSwayController.dispose();
    _sparkleController.dispose();
    _burstController.dispose();
    _happyBounceController.dispose();
    _storyBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _floatController,
            _breathController,
            _blinkController,
            _bookSwayController,
            _sparkleController,
            _burstController,
            _happyBounceController,
            _storyBounceController,
          ]),
          builder: (context, _) {
            final bool isHappyBouncing = _happyBounceController.isAnimating;
            final bool isStoryBouncing = _storyBounceController.isAnimating;

            double translateY = _floatY.value;
            double scale = _breathScale.value;

            if (isHappyBouncing) {
              translateY += _happyJump.value;
              scale *= _happyScale.value;
            } else if (isStoryBouncing) {
              translateY += _storyJump.value;
              scale *= _storyScale.value;
            }

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _GroundShadow(
                      isHappy: widget.isHappy,
                      glowPulse: _breathScale.value,
                    ),
                    CustomPaint(
                      painter: _SoftGlowPainter(
                        pulse: _breathScale.value,
                        isHappy: widget.isHappy,
                      ),
                      size: const Size(250, 250),
                    ),
                    CustomPaint(
                      painter: _StorySparklePainter(
                        progress: _sparkleController.value,
                        burstProgress: _burstController.value,
                        isHappy: widget.isHappy,
                      ),
                      size: const Size(260, 260),
                    ),
                    CustomPaint(
                      painter: _StoryBuddyRobotPainter(
                        expression: _expression,
                        eyeOpenAmount: _blinkAmount.value,
                        bookSway: _bookSway.value,
                      ),
                      size: _robotSize,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({
    required this.isHappy,
    required this.glowPulse,
  });

  final bool isHappy;
  final double glowPulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (isHappy ? 124 : 104) * glowPulse,
      height: 18,
      margin: const EdgeInsets.only(top: 172),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primary.withValues(alpha: isHappy ? 0.26 : 0.15),
            blurRadius: isHappy ? 24 : 16,
            spreadRadius: isHappy ? 3 : 1,
          ),
        ],
      ),
    );
  }
}

class _SoftGlowPainter extends CustomPainter {
  _SoftGlowPainter({required this.pulse, required this.isHappy});

  final double pulse;
  final bool isHappy;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.42);
    final double radius = size.width * 0.36 * pulse * (isHappy ? 1.06 : 1);

    final Paint glow = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          AppStyles.primary.withValues(alpha: isHappy ? 0.28 : 0.18),
          AppStyles.secondary.withValues(alpha: isHappy ? 0.14 : 0.08),
          Colors.transparent,
        ],
        [0, 0.55, 1],
      );
    canvas.drawCircle(center, radius, glow);
  }

  @override
  bool shouldRepaint(covariant _SoftGlowPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.isHappy != isHappy;
  }
}

class _StorySparklePainter extends CustomPainter {
  _StorySparklePainter({
    required this.progress,
    required this.burstProgress,
    required this.isHappy,
  });

  final double progress;
  final double burstProgress;
  final bool isHappy;

  static const List<_SparkleSpec> _ambient = [
    _SparkleSpec(0.02, 0.68, 3.5, AppStyles.secondary),
    _SparkleSpec(0.14, 0.74, 3, AppStyles.primary),
    _SparkleSpec(0.28, 0.66, 4, AppStyles.secondary),
    _SparkleSpec(0.41, 0.78, 2.8, Color(0xFFFFB347)),
    _SparkleSpec(0.55, 0.7, 3.5, AppStyles.primary),
    _SparkleSpec(0.67, 0.76, 3, AppStyles.secondary),
    _SparkleSpec(0.79, 0.64, 2.5, AppStyles.primary),
    _SparkleSpec(0.91, 0.72, 3.2, Color(0xFFFFB347)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.4);

    for (int i = 0; i < _ambient.length; i++) {
      final _SparkleSpec spec = _ambient[i];
      final double angle = (spec.angleOffset + progress) * 2 * math.pi;
      final double radius = size.width * spec.orbitRadius * 0.5;
      final Offset pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final double twinkle =
          0.45 + 0.55 * math.sin(progress * math.pi * 4 + i * 1.3);
      _drawStar(canvas, pos, spec.size * twinkle, spec.color, twinkle);
    }

    if (isHappy && burstProgress > 0) {
      for (int i = 0; i < 8; i++) {
        final double angle = i * math.pi / 4;
        final double distance = 50 + burstProgress * 60;
        final Offset pos = Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        );
        _drawStar(
          canvas,
          pos,
          5.5 * (1 - burstProgress * 0.4),
          AppStyles.secondary,
          1 - burstProgress,
        );
      }
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    if (alpha <= 0.05 || radius <= 0.5) {
      return;
    }

    final Paint paint = Paint()
      ..color = color.withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.3, paint);

    final Path star = Path();
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2;
      final Offset tip = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final Offset notch = Offset(
        center.dx + math.cos(angle + math.pi / 4) * radius * 0.26,
        center.dy + math.sin(angle + math.pi / 4) * radius * 0.26,
      );
      if (i == 0) {
        star.moveTo(tip.dx, tip.dy);
      } else {
        star.lineTo(tip.dx, tip.dy);
      }
      star.lineTo(notch.dx, notch.dy);
    }
    star.close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(covariant _StorySparklePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.burstProgress != burstProgress ||
        oldDelegate.isHappy != isHappy;
  }
}

class _SparkleSpec {
  const _SparkleSpec(this.angleOffset, this.orbitRadius, this.size, this.color);

  final double angleOffset;
  final double orbitRadius;
  final double size;
  final Color color;
}

class _StoryBuddyRobotPainter extends CustomPainter {
  _StoryBuddyRobotPainter({
    required this.expression,
    required this.eyeOpenAmount,
    required this.bookSway,
  });

  final _BuddyExpression expression;
  final double eyeOpenAmount;
  final double bookSway;

  static const Color _purpleDark = Color(0xFF5A52E0);
  static const Color _purpleLight = Color(0xFF8B83FF);
  static const Color _pageLeft = Color(0xFFFFF0B8);
  static const Color _pageRight = Color(0xFFFFFBEF);
  static const Color _bookAccent = Color(0xFFFFC93D);

  bool get _isHappy => expression == _BuddyExpression.happy;
  bool get _isConfused => expression == _BuddyExpression.confused;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    _drawLegs(canvas, cx, size.height * 0.86);
    _drawBody(canvas, cx, size.height * 0.58);
    _drawArmsAndBook(canvas, cx, size.height * 0.58);
    _drawHead(canvas, cx, size.height * 0.28);
  }

  void _drawLegs(Canvas canvas, double cx, double footY) {
    final Paint legPaint = Paint()..color = _purpleDark;
    final Paint footPaint = Paint()..color = AppStyles.secondary;

    for (final double side in [-1.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + side * 22, footY - 14),
            width: 18,
            height: 24,
          ),
          const Radius.circular(9),
        ),
        legPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + side * 22, footY),
            width: 26,
            height: 12,
          ),
          const Radius.circular(6),
        ),
        footPaint,
      );
    }
  }

  void _drawBody(Canvas canvas, double cx, double bodyCenterY) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bodyCenterY),
          width: 96,
          height: 78,
        ),
        const Radius.circular(22),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, bodyCenterY - 40),
          Offset(cx, bodyCenterY + 40),
          const [AppStyles.primary, _purpleDark],
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bodyCenterY - 4),
          width: 52,
          height: 38,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = AppStyles.secondary,
    );

    canvas.drawCircle(
      Offset(cx, bodyCenterY - 4),
      8,
      Paint()..color = _purpleDark,
    );
    canvas.drawCircle(
      Offset(cx, bodyCenterY - 4),
      4,
      Paint()..color = Colors.white,
    );
  }

  void _drawArmsAndBook(Canvas canvas, double cx, double bodyCenterY) {
    final Paint armPaint = Paint()..color = _purpleLight;

    canvas.save();
    canvas.translate(cx, bodyCenterY + 6);
    canvas.rotate(bookSway);

    for (final double side in [-1.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(side * 58, 0),
            width: 18,
            height: 36,
          ),
          const Radius.circular(9),
        ),
        armPaint,
      );
    }

    _drawOpenBook(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawOpenBook(Canvas canvas, Offset center) {
    const double pageWidth = 36;
    const double pageHeight = 46;
    const double spread = 38;

    final RRect leftPage = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - spread / 2, center.dy),
        width: pageWidth,
        height: pageHeight,
      ),
      const Radius.circular(12),
    );
    final RRect rightPage = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + spread / 2, center.dy),
        width: pageWidth,
        height: pageHeight,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      leftPage,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx - spread, center.dy - 24),
          Offset(center.dx - spread / 2, center.dy + 24),
          const [_pageLeft, Color(0xFFFFE082)],
        ),
    );
    canvas.drawRRect(
      rightPage,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx + spread / 2, center.dy - 24),
          Offset(center.dx + spread, center.dy + 24),
          const [_pageRight, Colors.white],
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy),
          width: 10,
          height: pageHeight + 6,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = _bookAccent,
    );

    final Paint linePaint = Paint()
      ..color = AppStyles.primary.withValues(alpha: 0.42)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final Paint colorLine = Paint()
      ..color = const Color(0xFFFF8FAB).withValues(alpha: 0.65)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final double y = center.dy - 13 + i * 11;
      canvas.drawLine(
        Offset(center.dx - spread / 2 - 15, y),
        Offset(center.dx - spread / 2 + 11, y),
        i == 1 ? colorLine : linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + spread / 2 - 11, y),
        Offset(center.dx + spread / 2 + 15, y),
        linePaint,
      );
    }

    _drawStarGlyph(
      canvas,
      Offset(center.dx - spread / 2 - 2, center.dy + 15),
      5.5,
      AppStyles.secondary,
    );
    canvas.drawCircle(
      Offset(center.dx + spread / 2 + 2, center.dy + 14),
      4,
      Paint()..color = const Color(0xFF64B5F6),
    );

    final Paint border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppStyles.primary.withValues(alpha: 0.22);
    canvas.drawRRect(leftPage, border);
    canvas.drawRRect(rightPage, border);
  }

  void _drawHead(Canvas canvas, double cx, double headCenterY) {
    if (_isConfused) {
      canvas.save();
      canvas.translate(cx, headCenterY);
      canvas.rotate(-0.08);
      canvas.translate(-cx, -headCenterY);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, headCenterY),
          width: 88,
          height: 76,
        ),
        const Radius.circular(26),
      ),
      Paint()..color = AppStyles.primary,
    );

    for (final double side in [-1.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + side * 48, headCenterY - 8),
            width: 14,
            height: 22,
          ),
          const Radius.circular(7),
        ),
        Paint()..color = AppStyles.secondary,
      );
    }

    canvas.drawLine(
      Offset(cx, headCenterY - 38),
      Offset(cx, headCenterY - 52),
      Paint()
        ..color = AppStyles.secondary
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx, headCenterY - 56),
      7,
      Paint()..color = AppStyles.secondary,
    );
    canvas.drawCircle(
      Offset(cx, headCenterY - 56),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    if (_isConfused) {
      _drawConfusedBrows(canvas, cx, headCenterY);
    }

    _drawEye(canvas, Offset(cx - 24, headCenterY - 4), pupilShift: _isConfused ? -2 : 0);
    _drawEye(canvas, Offset(cx + 24, headCenterY - 4), pupilShift: _isConfused ? 2 : 0);

    if (_isHappy) {
      canvas.drawCircle(
        Offset(cx - 36, headCenterY + 12),
        8,
        Paint()..color = const Color(0xFFFF9EC4).withValues(alpha: 0.65),
      );
      canvas.drawCircle(
        Offset(cx + 36, headCenterY + 12),
        8,
        Paint()..color = const Color(0xFFFF9EC4).withValues(alpha: 0.65),
      );
    }

    _drawMouth(canvas, Offset(cx, headCenterY + 17));

    if (_isConfused) {
      final TextPainter question = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: AppStyles.secondary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      question.paint(
        canvas,
        Offset(cx - question.width / 2, headCenterY - 72),
      );
      canvas.restore();
    }
  }

  void _drawConfusedBrows(Canvas canvas, double cx, double headCenterY) {
    final Paint brow = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - 36, headCenterY - 20),
      Offset(cx - 14, headCenterY - 26),
      brow,
    );
    canvas.drawLine(
      Offset(cx + 14, headCenterY - 12),
      Offset(cx + 36, headCenterY - 14),
      brow,
    );
  }

  void _drawEye(Canvas canvas, Offset center, {double pupilShift = 0}) {
    const double eyeW = 30;
    const double eyeH = 32;
    final double open = eyeOpenAmount.clamp(0.06, 1.0);
    final double height = eyeH * open;

    if (_isHappy && open > 0.5) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: eyeW + 6, height: height + 6),
        Paint()
          ..color = AppStyles.secondary.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: center, width: eyeW, height: height),
      Paint()..color = Colors.white,
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: eyeW + 4, height: height + 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _purpleDark.withValues(alpha: 0.18),
    );

    if (open > 0.3) {
      final Offset pupilCenter = Offset(center.dx + pupilShift, center.dy + 1);
      canvas.drawCircle(
        pupilCenter,
        (_isHappy ? 8.5 : 8) * open,
        Paint()..color = AppStyles.textPrimary,
      );
      canvas.drawCircle(
        Offset(pupilCenter.dx - 3.5, pupilCenter.dy - 4),
        3.5 * open,
        Paint()..color = Colors.white,
      );
      if (_isHappy) {
        canvas.drawCircle(
          Offset(pupilCenter.dx + 4, pupilCenter.dy + 3),
          1.8 * open,
          Paint()..color = Colors.white.withValues(alpha: 0.75),
        );
      }
    }
  }

  void _drawMouth(Canvas canvas, Offset center) {
    final Paint mouthPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.96)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (_isConfused) {
      final Path wavy = Path()
        ..moveTo(center.dx - 14, center.dy + 2)
        ..quadraticBezierTo(
          center.dx - 7,
          center.dy - 4,
          center.dx,
          center.dy + 3,
        )
        ..quadraticBezierTo(
          center.dx + 7,
          center.dy + 10,
          center.dx + 14,
          center.dy + 2,
        );
      mouthPaint.strokeWidth = 3.5;
      canvas.drawPath(wavy, mouthPaint);
      return;
    }

    final Path smile = Path();
    if (_isHappy) {
      mouthPaint.strokeWidth = 4;
      smile.moveTo(center.dx - 22, center.dy - 3);
      smile.quadraticBezierTo(
        center.dx,
        center.dy + 18,
        center.dx + 22,
        center.dy - 3,
      );
      canvas.drawPath(smile, mouthPaint);

      final Path fill = Path()
        ..moveTo(center.dx - 20, center.dy - 1)
        ..quadraticBezierTo(center.dx, center.dy + 14, center.dx + 20, center.dy - 1)
        ..close();
      canvas.drawPath(
        fill,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    } else {
      mouthPaint.strokeWidth = 3.5;
      smile.moveTo(center.dx - 16, center.dy - 1);
      smile.quadraticBezierTo(
        center.dx,
        center.dy + 12,
        center.dx + 16,
        center.dy - 1,
      );
      canvas.drawPath(smile, mouthPaint);
    }
  }

  void _drawStarGlyph(Canvas canvas, Offset center, double radius, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path star = Path();
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2 - math.pi / 2;
      final Offset tip = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final Offset notch = Offset(
        center.dx + math.cos(angle + math.pi / 4) * radius * 0.35,
        center.dy + math.sin(angle + math.pi / 4) * radius * 0.35,
      );
      if (i == 0) {
        star.moveTo(tip.dx, tip.dy);
      } else {
        star.lineTo(tip.dx, tip.dy);
      }
      star.lineTo(notch.dx, notch.dy);
    }
    star.close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(covariant _StoryBuddyRobotPainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.eyeOpenAmount != eyeOpenAmount ||
        oldDelegate.bookSway != bookSway;
  }
}
