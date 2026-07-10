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
  String? _attemptStartedAt;

  Duration _elapsed = Duration.zero;

  final Set<int> _collected = <int>{};

  bool _completed = false;
  bool _isLoading = false;
  bool _isCompleting = false;

  AdventureMazeCubit({
    required AdventureMazeService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  })  : _service = service,
        super(const AdventureMazeInitial());

  Future<void> loadGame({int? startLevelId}) async {
    if (_isLoading) return;

    _isLoading = true;
    emit(const AdventureMazeLoading());

    try {
      final levels = await _service.getLevels(activityId);

      if (levels.isEmpty) {
        emit(const AdventureMazeError('لا توجد مستويات لهذا النشاط'));
        return;
      }

      debugPrint(
        'ADVENTURE MAZE loadGame | '
            'requested startLevelId=$startLevelId',
      );

      debugPrint(
        'ADVENTURE MAZE available levels='
            '${levels.map((level) => '${level.id}(#${level.levelNumber})').toList()}',
      );

      _level = levels.firstWhere(
            (level) => level.id == startLevelId,
        orElse: () => levels.first,
      );

      debugPrint(
        'ADVENTURE MAZE picked '
            'levelId=${_level!.id} (#${_level!.levelNumber})',
      );

      debugPrint(
        'ADVENTURE MAZE challenges='
            '${_level!.challenges.map((challenge) => '${challenge.challengeId}:${challenge.type}').toList()}',
      );

      final config = adventureMazeConfigs[_level!.id];

      if (config == null) {
        emit(
          AdventureMazeError(
            'لا توجد إعدادات إحداثيات للمستوى ${_level!.id}. '
                'يجب على المطوّر تعريفها.',
          ),
        );
        return;
      }

      _config = config;

      _attemptNumber = 1;
      _elapsed = Duration.zero;
      _collected.clear();
      _completed = false;
      _isCompleting = false;

      _attemptStartedAt = DateTime.now().toUtc().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt!,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _runSafely(
        label: 'ADVENTURE MAZE START ACTIVITY EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'STARTED',
        ),
      );

      await _runSafely(
        label: 'ADVENTURE MAZE START LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'STARTED',
        ),
      );

      _emitLoaded();
    } catch (error) {
      emit(
        AdventureMazeError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  void _emitLoaded({
    int? activeChallengeId,
    bool clearActive = false,
  }) {
    if (_level == null || _config == null) return;

    emit(
      AdventureMazeLoaded(
        level: _level!,
        config: _config!,
        challenges: _level!.challenges,
        collectedChallengeIds: Set<int>.from(_collected),
        currentAttemptId: _attemptId,
        attemptNumber: _attemptNumber,
        elapsed: _elapsed,
        activeChallengeId: clearActive ? null : activeChallengeId,
      ),
    );
  }

  void onStarTouched(int challengeId) {
    if (_completed || _isCompleting || _level == null) return;
    if (_collected.contains(challengeId)) return;

    final currentState = state;

    if (currentState is AdventureMazeLoaded &&
        currentState.activeChallengeId != null) {
      return;
    }

    _emitLoaded(activeChallengeId: challengeId);
  }

  bool onChoiceSelected(int challengeId, StarChoice choice) {
    if (_completed || _isCompleting || _level == null) return false;

    final challenge = _level!.challenges.firstWhere(
          (item) => item.challengeId == challengeId,
      orElse: () => const StarChallenge(
        challengeId: -1,
        type: '',
        prompt: '',
        choices: [],
      ),
    );

    if (challenge.challengeId == -1) return false;

    final isValid = challenge.isEmotional ? true : choice.isCorrect;

    if (!isValid) {
      return false;
    }

    _collected.add(challengeId);
    _emitLoaded(clearActive: true);

    return true;
  }

  void dismissPopup() {
    _emitLoaded(clearActive: true);
  }

  Future<void> onBallFellInHole() async {
    if (_completed ||
        _isCompleting ||
        _level == null ||
        _attemptId <= 0) {
      return;
    }

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _runSafely(
        label: 'ADVENTURE MAZE FAILED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'FAILED',
        ),
      );

      _attemptNumber += 1;
      _attemptStartedAt = DateTime.now().toUtc().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt!,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _runSafely(
        label: 'ADVENTURE MAZE RETRIED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'RETRIED',
        ),
      );

      emit(
        AdventureMazeFailed(
          currentAttemptId: _attemptId,
          attemptNumber: _attemptNumber,
        ),
      );

      _emitLoaded();
    } catch (error) {
      debugPrint('ADVENTURE MAZE FAIL ERROR: $error');

      emit(
        AdventureMazeError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> onBallReachedEnd() async {
    if (_completed || _isCompleting || _level == null) return;

    if (_collected.length < _level!.challenges.length) {
      debugPrint(
        'ADVENTURE MAZE reached end but stars incomplete: '
            '${_collected.length}/${_level!.challenges.length}',
      );
      return;
    }

    if (_attemptId <= 0) {
      emit(
        const AdventureMazeError(
          'تعذر العثور على محاولة المستوى الحالية',
        ),
      );
      return;
    }

    _isCompleting = true;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: true,
      );

      // حفظ إكمال الـActivity Session أساسي، لذلك يتم قبل الـEvents.
      await _service.completeActivitySession(activitySessionId);

      _completed = true;

      // فشل تسجيل الـEvents لا يجب أن يلغي حفظ التقدم.
      await _runSafely(
        label: 'ADVENTURE MAZE COMPLETED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'COMPLETED',
        ),
      );

      await _runSafely(
        label: 'ADVENTURE MAZE COMPLETED ACTIVITY EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'COMPLETED',
        ),
      );

      emit(const AdventureMazeComplete());
    } catch (error) {
      _completed = false;

      debugPrint('ADVENTURE MAZE COMPLETE ERROR: $error');

      emit(
        const AdventureMazeError(
          'تعذر حفظ تقدم النشاط، حاول مرة أخرى',
        ),
      );
    } finally {
      _isCompleting = false;
    }
  }

  void onTimerTick() {
    if (_completed || _isCompleting) return;

    _elapsed += const Duration(seconds: 1);

    final currentState = state;

    if (currentState is AdventureMazeLoaded) {
      emit(
        currentState.copyWith(
          elapsed: _elapsed,
        ),
      );
    }
  }

  Future<void> logExitIfNotCompleted() async {
    if (_completed || _level == null || _attemptId <= 0) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _runSafely(
        label: 'ADVENTURE MAZE EXIT EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'ENDED',
        ),
      );
    } catch (error) {
      debugPrint('ADVENTURE MAZE EXIT ERROR: $error');
    }
  }

  Future<void> _runSafely({
    required String label,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
    } catch (error) {
      debugPrint('$label: $error');
    }
  }
}
