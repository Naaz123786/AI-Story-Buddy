import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_story_buddy/main.dart';
import 'package:ai_story_buddy/models/quiz_model.dart';
import 'package:ai_story_buddy/providers/audio_provider.dart';
import 'package:ai_story_buddy/providers/quiz_provider.dart';
import 'package:ai_story_buddy/services/tts_service.dart';

void main() {
  testWidgets('AI Story Buddy renders story screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AIStoryBuddyApp()),
    );

    expect(find.text('AI Story Buddy'), findsOneWidget);
    expect(find.text('Read Me A Story'), findsOneWidget);
    expect(find.textContaining('Pip'), findsWidgets);
  });

  testWidgets('Celebration card appears after correct quiz answer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioProvider.overrideWith((ref) {
            final notifier = AudioNotifier(ref.watch(ttsServiceProvider));
            notifier.state = AudioState.completed;
            return notifier;
          }),
        ],
        child: const AIStoryBuddyApp(),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AIStoryBuddyApp)),
    );
    container.read(quizProvider.notifier).reveal();
    container
        .read(quizProvider.notifier)
        .handleAnswer('Blue', QuizModel.pipGearQuiz);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('🎉 Awesome!'), findsOneWidget);
    expect(find.text('Pip found his blue gear!'), findsOneWidget);
    expect(find.text('Story Star Earned'), findsOneWidget);
  });
}
