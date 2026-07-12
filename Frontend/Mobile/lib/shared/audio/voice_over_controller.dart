import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../models/voice_over/voice_over_model.dart';
import '../../services/voice_over/voice_over_service.dart';

class VoiceOverController {
  final AudioPlayer _player;
  final VoiceOverService _service;

  int _requestVersion = 0;
  bool _disposed = false;

  VoiceOverController({
    AudioPlayer? player,
    VoiceOverService? service,
  })  : _player = player ?? AudioPlayer(),
        _service = service ?? VoiceOverService();

  Future<void> playIntro({
    required int activityId,
  }) async {
    await _play(
          () => _service.getActivityIntroVoiceOver(activityId),
    );
  }

  Future<void> playLevel({
    required int activityId,
    required int levelId,
  }) async {
    await _play(
          () => _service.getActivityLevelVoiceOver(
        activityId: activityId,
        levelId: levelId,
      ),
    );
  }

  Future<void> playGlobal(
      GlobalVoiceOverType type,
      ) async {
    await _play(
          () => _service.getGlobalVoiceOver(type),
    );
  }

  Future<void> playMazeQuestion({
    required int levelId,
    required int challengeId,
  }) async {
    await _play(
          () => _service.getMazeQuestionVoiceOver(
        levelId: levelId,
        challengeId: challengeId,
      ),
    );
  }

  Future<void> _play(
      Future<VoiceOverModel> Function() loadVoiceOver,
      ) async {
    final requestVersion = ++_requestVersion;

    try {
      await _player.stop();

      final voiceOver = await loadVoiceOver();

      if (_disposed || requestVersion != _requestVersion) {
        return;
      }

      await _player.play(
        UrlSource(voiceOver.url),
      );
    } catch (error) {
      // Voice-over must never block or break the activity.
      debugPrint('VOICE OVER PLAYBACK ERROR: $error');
    }
  }

  Future<void> stop() async {
    _requestVersion++;

    try {
      await _player.stop();
    } catch (error) {
      debugPrint('VOICE OVER STOP ERROR: $error');
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;
    _requestVersion++;

    try {
      await _player.stop();
      await _player.dispose();
    } catch (error) {
      debugPrint('VOICE OVER DISPOSE ERROR: $error');
    }
  }
}
