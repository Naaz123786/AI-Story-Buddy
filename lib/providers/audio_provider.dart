import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tts_service.dart';

enum AudioState {
  idle,
  loading,
  playing,
  completed,
  error,
}

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier(this._ttsService) : super(AudioState.idle);

  final TtsService _ttsService;

  static const String storyText =
      'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...';

  bool get isBusy =>
      state == AudioState.loading || state == AudioState.playing;

  Future<void> readStory() async {
    if (isBusy) {
      return;
    }

    state = AudioState.loading;

    try {
      await _ttsService.initialize();
      state = AudioState.playing;
      await _ttsService.speak(storyText);
      state = AudioState.completed;
    } catch (_) {
      state = AudioState.error;
    }
  }

  Future<void> retry() async {
    state = AudioState.idle;
    await readStory();
  }

  void reset() {
    state = AudioState.idle;
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier(ref.watch(ttsServiceProvider));
});

final isAudioBusyProvider = Provider<bool>((ref) {
  final audioState = ref.watch(audioProvider);
  return audioState == AudioState.loading ||
      audioState == AudioState.playing;
});

final showQuizProvider = Provider<bool>((ref) {
  return ref.watch(audioProvider) == AudioState.completed;
});

final showAudioErrorProvider = Provider<bool>((ref) {
  return ref.watch(audioProvider) == AudioState.error;
});
