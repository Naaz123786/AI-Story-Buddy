import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animations/shake_animation.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_styles.dart';
import 'option_button.dart';

class QuizCard extends ConsumerStatefulWidget {
  const QuizCard({super.key});

  @override
  ConsumerState<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends ConsumerState<QuizCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).reveal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final QuizModel quiz = ref.watch(quizModelProvider);
    final QuizViewState quizView = ref.watch(quizProvider);
    final int shakeTrigger = quizView.shakeTrigger;
    final String? lastWrong = quizView.lastWrongAnswer;
    final bool isSuccess = quizView.phase == QuizState.success;

    return RepaintBoundary(
      child: ShakeAnimation(
        trigger: shakeTrigger,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSuccess
                  ? AppStyles.success.withValues(alpha: 0.5)
                  : AppStyles.primary.withValues(alpha: 0.18),
              width: 2,
            ),
            boxShadow: AppStyles.softShadow(AppStyles.primary, blur: 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppStyles.secondary.withValues(alpha: 0.45),
                      AppStyles.secondary.withValues(alpha: 0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🧩', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Quiz Time!',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppStyles.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                quiz.question,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                  color: AppStyles.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...quiz.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OptionButton(
                    label: option,
                    isWrong: lastWrong == option,
                    isLocked: isSuccess,
                    isCorrectSelected: isSuccess && option == quiz.answer,
                    onTap: () {
                      ref
                          .read(quizProvider.notifier)
                          .handleAnswer(option, quiz);
                    },
                  ),
                ),
              ),
              if (lastWrong != null && !isSuccess) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppStyles.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppStyles.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('🤔', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Not quite! Give it another try, explorer!',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppStyles.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
