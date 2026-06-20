import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_styles.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/floating_stars_background.dart';
import '../widgets/quiz_card.dart';
import '../widgets/read_story_button.dart';
import '../widgets/story_card.dart';
import '../widgets/success_celebration_card.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late final ConfettiController _confettiController;
  int _storyStars = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isQuizSuccessProvider, (previous, next) {
      if (next) {
        _confettiController.play();
        if (_storyStars == 0) {
          setState(() => _storyStars = 1);
        }
      }
    });

    ref.listen<bool>(showQuizProvider, (previous, next) {
      if (next) {
        ref.read(quizProvider.notifier).reveal();
      }
    });

    ref.listen<AudioState>(audioProvider, (previous, next) {
      if (next == AudioState.completed) {
        ref.read(quizProvider.notifier).reveal();
      }
      if (next == AudioState.loading || next == AudioState.playing) {
        ref.read(quizProvider.notifier).reset();
        if (_storyStars > 0) {
          setState(() => _storyStars = 0);
        }
      }
    });

    final bool isAudioBusy = ref.watch(isAudioBusyProvider);
    final bool showQuiz = ref.watch(showQuizProvider);
    final bool showError = ref.watch(showAudioErrorProvider);
    final AudioState audioState = ref.watch(audioProvider);
    final bool isHappy = ref.watch(isQuizSuccessProvider);
    final int wrongAnswerTrigger = ref.watch(quizProvider).shakeTrigger;

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppStyles.screenGradient),
            child: SizedBox.expand(),
          ),
          const Positioned.fill(
            child: FloatingStarsBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppStyles.cardHeaderGradient.createShader(
                                bounds,
                              ),
                              child: const Text(
                                'AI Story Buddy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Meet Pip, your story buddy!',
                              style: AppStyles.subtitle,
                            ),
                          ],
                        ),
                      ),
                      if (_storyStars > 0)
                        AnimatedScale(
                          scale: 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppStyles.softShadow(
                                AppStyles.secondary,
                                blur: 12,
                              ),
                            ),
                            child: Text(
                              '⭐ +$_storyStars',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppStyles.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BuddyWidget(
                    isHappy: isHappy,
                    wrongAnswerTrigger: wrongAnswerTrigger,
                    isStoryFinished: audioState == AudioState.completed,
                  ),
                  const SizedBox(height: 8),
                  const StoryCard(),
                  const SizedBox(height: 14),
                  ReadStoryButton(
                    isBusy: isAudioBusy,
                    audioState: audioState,
                    onPressed: () {
                      ref.read(audioProvider.notifier).readStory();
                    },
                  ),
                  if (showError) ...[
                    const SizedBox(height: 10),
                    _ErrorBanner(
                      onRetry: () {
                        ref.read(audioProvider.notifier).retry();
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 650),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final Animation<double> scale = Tween<double>(
                        begin: 0.92,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      );
                      final Animation<Offset> slide = Tween<Offset>(
                        begin: const Offset(0, 0.12),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slide,
                          child: ScaleTransition(scale: scale, child: child),
                        ),
                      );
                    },
                    child: showQuiz
                        ? Padding(
                            key: ValueKey(
                              isHappy ? 'celebration-section' : 'quiz-section',
                            ),
                            padding: const EdgeInsets.only(bottom: 4),
                            child: isHappy
                                ? SuccessCelebrationCard(
                                    key: ValueKey('celebration-$_storyStars'),
                                  )
                                : const QuizCard(),
                          )
                        : const SizedBox.shrink(key: ValueKey('quiz-hidden')),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppStyles.primary,
                AppStyles.secondary,
                AppStyles.success,
                AppStyles.error,
                Color(0xFF2196F3),
              ],
              numberOfParticles: 36,
              maxBlastForce: 32,
              minBlastForce: 16,
              gravity: 0.12,
              emissionFrequency: 0.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppStyles.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Oops! Pip couldn\'t tell the story right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppStyles.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles.error,
              side: const BorderSide(color: AppStyles.error),
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
