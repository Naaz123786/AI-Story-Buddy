import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_model.dart';

enum QuizState {
  hidden,
  answering,
  success,
}

class QuizViewState {
  const QuizViewState({
    this.phase = QuizState.hidden,
    this.lastWrongAnswer,
    this.shakeTrigger = 0,
  });

  final QuizState phase;
  final String? lastWrongAnswer;
  final int shakeTrigger;

  QuizViewState copyWith({
    QuizState? phase,
    String? lastWrongAnswer,
    int? shakeTrigger,
    bool clearWrongAnswer = false,
  }) {
    return QuizViewState(
      phase: phase ?? this.phase,
      lastWrongAnswer:
          clearWrongAnswer ? null : (lastWrongAnswer ?? this.lastWrongAnswer),
      shakeTrigger: shakeTrigger ?? this.shakeTrigger,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizViewState> {
  QuizNotifier() : super(const QuizViewState());

  void reveal() {
    if (state.phase == QuizState.hidden) {
      state = state.copyWith(phase: QuizState.answering, clearWrongAnswer: true);
    }
  }

  void handleAnswer(String selected, QuizModel quiz) {
    if (state.phase != QuizState.answering) {
      return;
    }

    if (quiz.isCorrect(selected)) {
      state = state.copyWith(
        phase: QuizState.success,
        clearWrongAnswer: true,
      );
      return;
    }

    state = state.copyWith(
      lastWrongAnswer: selected,
      shakeTrigger: state.shakeTrigger + 1,
    );
  }

  void reset() {
    state = const QuizViewState();
  }
}

final quizModelProvider = Provider<QuizModel>((ref) {
  return QuizModel.pipGearQuiz;
});

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizViewState>((ref) {
  return QuizNotifier();
});

final isQuizSuccessProvider = Provider<bool>((ref) {
  return ref.watch(quizProvider).phase == QuizState.success;
});
