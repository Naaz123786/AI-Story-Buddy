import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _flutterTts = FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.1);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await initialize();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  void dispose() {
    unawaited(stop());
  }
}
