import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activities/adventure_maze/config/adventure_maze_level_config.dart';
import '../../models/activities/adventure_maze/adventure_maze_models.dart';
import '../../services/activities/adventure_maze_service.dart';
import 'adventure_maze_state.dart';

class AdventureMazeCubit extends Cubit<AdventureMazeState> {
  final AdventureMazeService _service;

  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  AdventureMazeLevel? _level;
  AdventureMazeLevelConfig? _config;
  int _attemptId = 0;
  int _attemptNumber = 1;
  Duration _elapsed = Duration.zero;
  final Set<int> _collected = <int>{};
  bool _completed = false;
  bool _isLoading = false;

  AdventureMazeCubit({
    required AdventureMazeService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  })  : _service = service,
        super(const AdventureMazeInitial());

  // ─── Load ────────────────────────────────────────────────────────────────

  Future<void> loadGame({int? startLevelId}) async {
    if (_isLoading) return;
    _isLoading = true;
    emit(const AdventureMazeLoading());

    try {
      final levels = await _service.getLevels(activityId);
      if (levels.isEmpty) {
        emit(const AdventureMazeError('لا توجد مستويات لهذا النشاط'));
        _isLoading = false;
        return;
      }

      debugPrint(
          'ADVENTURE MAZE loadGame | requested startLevelId=$startLevelId');
      debugPrint(
          'ADVENTURE MAZE available levels=${levels.map((l) => "${l.id}(#${l.levelNumber})").toList()}');

      _level = levels.firstWhere(
        (l) => l.id == startLevelId,
        orElse: () => levels.first,
      );

      debugPrint(
          'ADVENTURE MAZE picked levelId=${_level!.id} (#${_level!.levelNumber})');
      debugPrint(
          'ADVENTURE MAZE challenges=${_level!.challenges.map((c) => "${c.challengeId}:${c.type}").toList()}');

      final config = adventureMazeConfigs[_level!.id];
      if (config == null) {
        emit(AdventureMazeError(
            'لا توجد إعدادات إحداثيات للمستوى ${_level!.id}. يجب على المطوّر تعريفها.'));
        _isLoading = false;
        return;
      }
      _config = config;

      _attemptNumber = 1;
      _elapsed = Duration.zero;
      _collected.clear();
      _completed = false;

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'STARTED',
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'STARTED',
      );

      _isLoading = false;
      _emitLoaded();
    } catch (e) {
      _isLoading = false;
      emit(AdventureMazeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _emitLoaded({int? activeChallengeId, bool clearActive = false}) {
    if (_level == null || _config == null) return;
    emit(AdventureMazeLoaded(
      level: _level!,
      config: _config!,
      challenges: _level!.challenges,
      collectedChallengeIds: Set<int>.from(_collected),
      currentAttemptId: _attemptId,
      attemptNumber: _attemptNumber,
      elapsed: _elapsed,
      activeChallengeId:
          clearActive ? null : activeChallengeId,
    ));
  }

  // ─── Star collision → open popup, pause game ────────────────────────────

  /// Called by the Flame game when the ball touches an uncollected star.
  /// Only opens a popup if no other popup is currently open.
  void onStarTouched(int challengeId) {
    if (_completed || _level == null) return;
    if (_collected.contains(challengeId)) return;
    final s = state;
    if (s is AdventureMazeLoaded && s.activeChallengeId != null) return;
    _emitLoaded(activeChallengeId: challengeId);
  }

  /// Called when the child taps a choice inside the popup.
  /// Returns true if the answer counted as valid and the star was collected.
  bool onChoiceSelected(int challengeId, StarChoice choice) {
    if (_completed || _level == null) return false;

    final challenge = _level!.challenges.firstWhere(
      (c) => c.challengeId == challengeId,
      orElse: () => const StarChallenge(
        challengeId: -1,
        type: '',
        prompt: '',
        choices: [],
      ),
    );
    if (challenge.challengeId == -1) return false;

    // Validation rule per §6 of the spec.
    // cognitive → only the choice marked isCorrect=true counts.
    // emotional → every choice counts (spec: "all choices have isCorrect:true").
    final isValid = challenge.isEmotional ? true : choice.isCorrect;
    if (!isValid) {
      // Wrong on a cognitive question: keep popup open, no penalty.
      return false;
    }

    _collected.add(challengeId);
    _emitLoaded(clearActive: true);
    return true;
  }

  /// Manually close the popup without answering (e.g. back button pressed).
  void dismissPopup() {
    _emitLoaded(clearActive: true);
  }

  // ─── Ball fell in a hole → failed attempt, reset to start ─────────────────

  Future<void> onBallFellInHole() async {
    if (_completed || _level == null) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        completed: false,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FAILED',
      );

      _attemptNumber += 1;
      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'RETRIED',
      );
    } catch (e) {
      debugPrint('ADVENTURE MAZE FAIL ERROR: $e');
    }

    emit(AdventureMazeFailed(
      currentAttemptId: _attemptId,
      attemptNumber: _attemptNumber,
    ));

    // Collected stars persist — only ball position resets.
    _emitLoaded();
  }

  // ─── Ball reached end → complete ─────────────────────────────────────────

  Future<void> onBallReachedEnd() async {
    if (_completed || _level == null) return;

    // Guard: only complete if every star has been collected.
    if (_collected.length < _level!.challenges.length) {
      debugPrint(
          'ADVENTURE MAZE reached end but stars incomplete: ${_collected.length}/${_level!.challenges.length}');
      return;
    }
    _completed = true;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        completed: true,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'COMPLETED',
      );
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );
      await _service.completeActivitySession(activitySessionId);
    } catch (e) {
      debugPrint('ADVENTURE MAZE COMPLETE ERROR: $e');
    }

    emit(const AdventureMazeComplete());
  }

  // ─── Timer ────────────────────────────────────────────────────────────────

  void onTimerTick() {
    if (_completed) return;
    _elapsed += const Duration(seconds: 1);
    final s = state;
    if (s is AdventureMazeLoaded) {
      emit(s.copyWith(elapsed: _elapsed));
    }
  }

  // ─── Exit without completing ──────────────────────────────────────────────

  Future<void> logExitIfNotCompleted() async {
    if (_completed) return;
    try {
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (e) {
      debugPrint('ADVENTURE MAZE EXIT ERROR: $e');
    }
  }
}
