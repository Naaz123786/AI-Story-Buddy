import 'package:flutter/material.dart';

import '../providers/audio_provider.dart';
import '../theme/app_styles.dart';

class StoryCard extends StatefulWidget {
  const StoryCard({super.key});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _iconController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _iconBob;
  late final Animation<double> _iconTilt;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _iconBob = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconTilt = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppStyles.primary.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primary.withValues(alpha: 0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StoryCardHeader(
                  iconBob: _iconBob,
                  iconTilt: _iconTilt,
                ),
                const _StoryCardBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryCardHeader extends StatelessWidget {
  const _StoryCardHeader({
    required this.iconBob,
    required this.iconTilt,
  });

  final Animation<double> iconBob;
  final Animation<double> iconTilt;

  static const LinearGradient _headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5A52E0),
      Color(0xFF6C63FF),
      Color(0xFF9B94FF),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: const BoxDecoration(
            gradient: _headerGradient,
          ),
          child: Row(
            children: [
              _AnimatedStorybookIcon(
                iconBob: iconBob,
                iconTilt: iconTilt,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tap below to hear Pip read!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFFE8E6FF),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('✨', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        Positioned(
          right: -12,
          top: -8,
          child: Icon(
            Icons.star_rounded,
            size: 28,
            color: AppStyles.secondary.withValues(alpha: 0.35),
          ),
        ),
        Positioned(
          left: 24,
          bottom: -1,
          right: 24,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppStyles.secondary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedStorybookIcon extends AnimatedWidget {
  _AnimatedStorybookIcon({
    required this.iconBob,
    required this.iconTilt,
  }) : super(listenable: Listenable.merge([iconBob, iconTilt]));

  final Animation<double> iconBob;
  final Animation<double> iconTilt;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, iconBob.value),
      child: Transform.rotate(
        angle: iconTilt.value,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _StoryCardBody extends StatelessWidget {
  const _StoryCardBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCFBFF),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppStyles.cardHeaderGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Adventure',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppStyles.primary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            AudioNotifier.storyText,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppStyles.textPrimary,
              height: 1.55,
              letterSpacing: 0.12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 18,
                color: AppStyles.primary.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 8),
              Text(
                'A tale from the Whispering Woods',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppStyles.textSecondary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
