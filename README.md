# AI Story Buddy

A production-ready Flutter application built for the **Peblo Internship Challenge**. AI Story Buddy lets children read a short story, hear it narrated with Text-to-Speech, and complete a fun quiz with delightful feedback.

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── quiz_model.dart
├── services/
│   └── tts_service.dart
├── providers/
│   ├── audio_provider.dart
│   └── quiz_provider.dart
├── screens/
│   └── story_screen.dart
├── widgets/
│   ├── buddy_widget.dart
│   ├── story_card.dart
│   ├── quiz_card.dart
│   └── option_button.dart
└── animations/
    └── shake_animation.dart
```

---

## Why Flutter?

Flutter was chosen because it delivers a **single codebase** for Android, iOS, and web with near-native performance. For an educational app targeting low-end Android devices (3 GB RAM), Flutter's:

- **Skia rendering engine** provides consistent 60 FPS animations
- **Ahead-of-time compilation** reduces runtime overhead
- **Widget composition model** enables fine-grained rebuild control

These qualities make Flutter ideal for kid-friendly apps that rely on smooth animations, TTS playback, and responsive touch feedback.

---

## Why Riverpod?

Riverpod was chosen over Provider or Bloc because it offers:

- **Compile-time safety** — providers are globally accessible without `BuildContext`
- **Fine-grained rebuilds** — `select` and derived providers minimize widget rebuilds
- **Testability** — providers can be overridden in widget tests
- **Clean separation** — audio and quiz logic live in dedicated notifiers

This aligns with Clean Architecture by keeping UI, state, and services decoupled.

---

## Audio State Flow

```
idle → loading → playing → completed
                  ↓
                error → (retry) → idle
```

| State     | Description                                      |
|-----------|--------------------------------------------------|
| `idle`    | Ready to narrate; button is enabled              |
| `loading` | TTS is initializing; button is disabled          |
| `playing` | Story is being read aloud; button is disabled    |
| `completed` | Narration finished; quiz is revealed           |
| `error`   | TTS failed; error banner with Retry is shown     |

When the user taps **Read Me A Story**, the `AudioNotifier` initializes `flutter_tts`, speaks the story text, and transitions through each state. On completion, a derived `showQuizProvider` triggers quiz reveal.

---

## Quiz State Flow

```
hidden → answering → success
              ↓
         (wrong answer → shake + retry, stay in answering)
```

| State       | Description                                    |
|-------------|------------------------------------------------|
| `hidden`    | Quiz section is not visible                    |
| `answering` | Quiz is visible; user can select an option     |
| `success`   | Correct answer; confetti + success banner      |

Wrong answers trigger a shake animation, haptic feedback, and a friendly retry message. The correct answer is **never revealed** on wrong attempts.

---

## Dynamic JSON Rendering

Quiz data is defined in `QuizModel.pipGearQuizJson` and parsed at runtime:

```dart
QuizModel.fromJson({
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
});
```

The `QuizCard` widget maps over `quiz.options` to build `OptionButton` widgets dynamically. This supports **3, 4, 5, or any number of options** without code changes — only the JSON needs updating.

---

## Error Handling

All TTS operations are wrapped in try/catch blocks inside `AudioNotifier.readStory()`. On failure:

1. State transitions to `error`
2. A friendly banner appears: *"Oops! Pip couldn't tell the story right now."*
3. A **Retry** button resets state and re-attempts narration

The app never crashes on TTS failures — errors are surfaced gracefully in the UI.

---

## Performance Optimization

Optimizations for low-end Android devices (3 GB RAM):

| Technique              | Where Applied                                      |
|------------------------|----------------------------------------------------|
| `const` widgets        | Story card, labels, static decorations             |
| `RepaintBoundary`      | Buddy, story card, quiz card, option buttons       |
| Riverpod selectors     | `isAudioBusyProvider`, `showQuizProvider`, etc.    |
| Controller disposal    | ConfettiController, TTS service, animation controllers |
| Minimal rebuilds       | Separate providers for audio vs quiz state           |
| Lightweight animations | Transform-based shake, AnimatedSwitcher for quiz   |

Target: **60 FPS** on mid-range and low-end devices.

---

## Caching Strategy

This app uses **on-device TTS** via `flutter_tts`, so no network requests or audio files are needed. Narration is generated locally in real time.

> If remote TTS services such as ElevenLabs were used, audio would be cached locally using `flutter_cache_manager`.

This would:
- Download audio once per story
- Store files in the app cache directory
- Serve cached audio on subsequent plays to save bandwidth and reduce latency

---

## AI Usage Disclosure

This project was built with assistance from AI coding tools (Cursor AI) for:

- Scaffolding the folder structure and boilerplate
- Generating the custom robot illustration painter
- Writing documentation and README content

All architecture decisions, state management patterns, and performance optimizations were reviewed and applied following Flutter best practices.

---

## Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| TTS completion detection | Used `awaitSpeakCompletion(true)` in `TtsService` |
| Quiz shake not triggering on repeated wrong answers | Moved to composite `QuizViewState` with `shakeTrigger` counter |
| Excessive rebuilds during narration | Derived providers (`isAudioBusyProvider`) isolate button state |
| OneDrive file locking on Windows builds | Run `gradlew --stop` and `flutter clean` before rebuilding |
| Low-end device performance | `RepaintBoundary`, `const` widgets, minimal animation complexity |

---

## Getting Started

```bash
flutter pub get
flutter create . --platforms=android,web,windows
flutter run
```

### Dependencies

- `flutter_riverpod` — State management
- `flutter_tts` — Text-to-Speech narration
- `confetti` — Celebration animation on correct answers

---

## Story & Quiz Content

**Story:** *"Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods..."*

**Quiz:** Dynamically rendered from JSON — *"What colour was Pip the Robot's lost gear?"* with options Red, Green, Blue, Yellow.

---

Built with ❤️ for the Peblo Internship Challenge.
