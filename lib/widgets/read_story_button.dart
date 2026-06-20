import 'package:flutter/material.dart';

import '../providers/audio_provider.dart';
import '../theme/app_styles.dart';

class ReadStoryButton extends StatefulWidget {
  const ReadStoryButton({
    super.key,
    required this.isBusy,
    required this.audioState,
    required this.onPressed,
  });

  final bool isBusy;
  final AudioState audioState;
  final VoidCallback onPressed;

  @override
  State<ReadStoryButton> createState() => _ReadStoryButtonState();
}

class _ReadStoryButtonState extends State<ReadStoryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  _ButtonVisual _visualFor(AudioState state) {
    return switch (state) {
      AudioState.idle => const _ButtonVisual('📖', 'Read Me A Story'),
      AudioState.loading => const _ButtonVisual('⏳', 'Preparing Story...'),
      AudioState.playing => const _ButtonVisual('🔊', 'Reading Story...'),
      AudioState.completed => const _ButtonVisual('✨', 'Story Finished!'),
      AudioState.error => const _ButtonVisual('📖', 'Read Me A Story'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final _ButtonVisual visual = _visualFor(widget.audioState);
    final bool isIdle = widget.audioState == AudioState.idle;
    final bool isCompleted = widget.audioState == AudioState.completed;

    return RepaintBoundary(
      child: Semantics(
        button: true,
        enabled: !widget.isBusy,
        label: visual.label,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final double scale =
                isIdle ? 1.0 + (_pulseController.value * 0.015) : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? AppStyles.successGradient
                    : AppStyles.buttonGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppStyles.softShadow(
                  isCompleted ? AppStyles.success : AppStyles.primary,
                  blur: 18,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: widget.isBusy ? null : widget.onPressed,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey<String>(visual.label),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.audioState == AudioState.loading)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        else
                          Text(
                            visual.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        const SizedBox(width: 10),
                        Text(
                          visual.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonVisual {
  const _ButtonVisual(this.emoji, this.label);

  final String emoji;
  final String label;
}
