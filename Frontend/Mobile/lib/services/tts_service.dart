import 'package:flutter_tts/flutter_tts.dart';

/// Small wrapper around flutter_tts for Arabic mascot speech.
/// Safe to call anywhere — failures are swallowed so the game never breaks
/// if a voice isn't available on the device/browser.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    try {
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);
      _ready = true;
    } catch (_) {
      // Ignore — speak() will simply be a no-op if init failed.
    }
  }

  Future<void> speak(String text) async {
    final cleaned = _stripEmoji(text).trim();
    if (cleaned.isEmpty) return;

    try {
      await init();
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (_) {
      // Never let speech failures break the game.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  String _stripEmoji(String text) {
    return text.replaceAll(
      RegExp(
        r'[\u2600-\u27BF\u2B00-\u2BFF]|[\uD83C-\uDBFF][\uDC00-\uDFFF]',
        unicode: true,
      ),
      '',
    );
  }
}