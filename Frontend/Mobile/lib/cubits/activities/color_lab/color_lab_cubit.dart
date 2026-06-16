import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/color_lab/color_lab_models.dart';
import '../../../services/activities/color_lab_service.dart';
import 'color_lab_state.dart';

class ColorLabCubit extends Cubit<ColorLabState> {
  final ColorLabService _service;

  static const FlutterSecureStorage _progressStorage =
  FlutterSecureStorage();

  // Context passed in from the resolver — never refetched here.
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  // Success threshold — 70% similarity (per design spec).
  static const double _successThreshold = 0.70;
  static const int _maxUndos = 3;

  ColorLabCubit({
    required ColorLabService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  })  : _service = service,
        super(const ColorLabInitial());

  // ---- internal mutable game data ----
  List<ColorLabLevel> _levels = [];
  int _currentLevelIndex = 0;
  int _currentChallengeIndex = 0;
  int _currentAttemptId = 0;
  int _attemptNumber = 1;
  int _undosUsed = 0;
  Duration _elapsed = Duration.zero;
  final List<ColorLabPaletteColor> _selected = [];
  bool _activityCompleted = false;
  bool _isLoading = false;

  ColorLabLevel get _level => _levels[_currentLevelIndex];

  String get _progressStorageKey {
    return 'color_lab_progress_child_${childId}_activity_$activityId';
  }

  // ===================== LOCAL PROGRESS BACKUP =====================

  Future<_ColorLabSavedProgress?> _readSavedProgress() async {
    final raw = await _progressStorage.read(
      key: _progressStorageKey,
    );

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return null;

      final levelIndex = _readInt(decoded['levelIndex']);
      final challengeIndex = _readInt(decoded['challengeIndex']);

      if (levelIndex == null || levelIndex < 0) return null;

      return _ColorLabSavedProgress(
        levelIndex: levelIndex,
        challengeIndex: challengeIndex ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _saveProgress({
    required int levelIndex,
    required int challengeIndex,
  }) async {
    await _progressStorage.write(
      key: _progressStorageKey,
      value: jsonEncode({
        'levelIndex': levelIndex,
        'challengeIndex': challengeIndex,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _clearSavedProgress() async {
    await _progressStorage.delete(
      key: _progressStorageKey,
    );
  }

  // ===================== LOAD =====================

  /// Step A — load levels, create first attempt, log STARTED events.
  Future<void> loadGame({
    int? startLevelId,
    int initialLevelNumber = 1,
  }) async {
    // Prevent duplicate loads (e.g. widget rebuilds) which cause 409 on attempts.
    if (_isLoading) return;
    _isLoading = true;

    emit(const ColorLabLoading());

    try {
      _levels = await _service.getLevels(activityId);

      if (_levels.isEmpty) {
        emit(const ColorLabError('لا توجد مستويات لهذا النشاط'));
        _isLoading = false;
        return;
      }

      // Keep only levels that actually have TARGET challenges to play.
      _levels = _levels.where((l) => l.challenges.isNotEmpty).toList();

      if (_levels.isEmpty) {
        emit(const ColorLabError('لا توجد تحديات في هذا النشاط بعد'));
        _isLoading = false;
        return;
      }

      final startPosition = await _resolveStartPosition(
        levels: _levels,
        startLevelId: startLevelId,
        initialLevelNumber: initialLevelNumber,
      );

      _currentLevelIndex = startPosition.levelIndex;
      _currentChallengeIndex = startPosition.challengeIndex;

      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      _attemptNumber = 1;
      _undosUsed = 0;
      _elapsed = Duration.zero;
      _selected.clear();
      _activityCompleted = false;

      debugPrint(
        'COLOR LAB: starting from levelIndex = $_currentLevelIndex, challengeIndex = $_currentChallengeIndex, levelId = ${_level.id}',
      );

      // Create first level attempt using the resolved starting level.
      _currentAttemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level.id,
      );

      // Log STARTED events (fire and forget, but awaited for ordering)
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
      emit(ColorLabError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<_ColorLabStartPosition> _resolveStartPosition({
    required List<ColorLabLevel> levels,
    required int? startLevelId,
    required int initialLevelNumber,
  }) async {
    if (levels.isEmpty) {
      return const _ColorLabStartPosition(
        levelIndex: 0,
        challengeIndex: 0,
      );
    }

    int backendLevelIndex = 0;

    if (startLevelId != null && startLevelId > 0) {
      final indexFromProgress = levels.indexWhere(
            (level) => level.id == startLevelId,
      );

      if (indexFromProgress != -1) {
        backendLevelIndex = indexFromProgress;
      } else {
        debugPrint(
          'COLOR LAB: startLevelId $startLevelId not found, fallback to level number',
        );

        backendLevelIndex = _levelIndexFromNumber(
          initialLevelNumber: initialLevelNumber,
          levelsLength: levels.length,
        );
      }
    } else {
      backendLevelIndex = _levelIndexFromNumber(
        initialLevelNumber: initialLevelNumber,
        levelsLength: levels.length,
      );
    }

    final savedProgress = await _readSavedProgress();

    if (savedProgress != null &&
        savedProgress.levelIndex >= 0 &&
        savedProgress.levelIndex < levels.length) {
      final maxChallengeIndex =
          levels[savedProgress.levelIndex].challenges.length - 1;

      final savedChallengeIndex = _clampInt(
        savedProgress.challengeIndex,
        0,
        maxChallengeIndex,
      );

      if (savedProgress.levelIndex > backendLevelIndex ||
          savedProgress.levelIndex == backendLevelIndex) {
        debugPrint(
          'COLOR LAB: using saved local progress levelIndex = ${savedProgress.levelIndex}, challengeIndex = $savedChallengeIndex',
        );

        return _ColorLabStartPosition(
          levelIndex: savedProgress.levelIndex,
          challengeIndex: savedChallengeIndex,
        );
      }
    }

    return _ColorLabStartPosition(
      levelIndex: backendLevelIndex,
      challengeIndex: 0,
    );
  }

  int _levelIndexFromNumber({
    required int initialLevelNumber,
    required int levelsLength,
  }) {
    if (levelsLength <= 0) return 0;

    if (initialLevelNumber <= 0 || initialLevelNumber > levelsLength) {
      return 0;
    }

    return _clampInt(initialLevelNumber - 1, 0, levelsLength - 1);
  }

  int _clampInt(int value, int min, int max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // ===================== COLOR PICK / UNDO / RESET =====================

  void pickColor(ColorLabPaletteColor color) {
    final palette = _level.paletteImage;
    final rawSlots = palette?.slots ?? 0;

    // Fallback to 5 when backend doesn't provide a positive slots value
    // matches the fallback used by ColorPaletteWidget for rendering.
    final maxSlots = rawSlots > 0 ? rawSlots : 5;

    debugPrint(
      'PICK COLOR: ${color.name} (selected: ${_selected.length}/$maxSlots)',
    );

    // Don't allow more picks than slots
    if (_selected.length >= maxSlots) return;

    _selected.add(color);
    _emitLoaded();
  }

  void undo() {
    if (_selected.isEmpty) return;

    _selected.removeLast();
    if (_undosUsed < _maxUndos) _undosUsed++;
    _emitLoaded();
  }

  void reset() {
    if (_selected.isEmpty && _undosUsed == 0) return;

    _selected.clear();
    _undosUsed = 0;
    _emitLoaded();
  }

  // ===================== TIMER =====================

  void onTimerTick() {
    _elapsed += const Duration(seconds: 1);

    final current = state;
    if (current is ColorLabLoaded) {
      emit(current.copyWith(elapsed: _elapsed));
    }
  }

  // ===================== SUBMIT =====================

  /// Decides success. Single-color challenges (Level 1) compare the one picked
  /// color to the target. Mix challenges (Level 2+) average picks and compare.
  Future<void> submitMix() async {
    if (_selected.isEmpty) return;

    final challenge = _level.challenges[_currentChallengeIndex];
    final target = challenge.primaryTarget;

    debugPrint('──────── SUBMIT ────────');
    debugPrint('CHALLENGE META: ${challenge.meta}');
    debugPrint(
      'TARGET: name=${target?.name} hex=${target?.hex} rgb=${target?.rgb}',
    );
    debugPrint(
      'SELECTED: ${_selected.map((c) => "${c.name}${c.rgb}").toList()}',
    );

    // No readable target → wrong (never auto-pass).
    if (target == null) {
      debugPrint('⚠️ TARGET NULL → wrong');
      await _handleWrong();
      return;
    }

    final tc = target.color;
    final targetRgb = [tc.red, tc.green, tc.blue];

    // 1) Name match on a single pick (most reliable for Level 1).
    if (_selected.length == 1) {
      final picked = _selected.first;
      final nameMatch = _sameColorName(picked.name, target.name);

      final pc = picked.color;
      final sim = _colorSimilarity([pc.red, pc.green, pc.blue], targetRgb);

      debugPrint(
        'SINGLE PICK | picked=${picked.name} target=${target.name} nameMatch=$nameMatch | similarity=${_pct(sim)}',
      );

      if (nameMatch || sim >= _successThreshold) {
        await _handleCorrect();
      } else {
        await _handleWrong();
      }
      return;
    }

    // 2) Mix of 2+ colors → mix and compare to target.
    const mixThreshold = 0.80;
    final mixed = _mixSelectedColors();
    final sim = _colorSimilarity(mixed, targetRgb);

    debugPrint(
      'MIX | mixedRgb=$mixed targetRgb=$targetRgb | similarity=${_pct(sim)} (need ${_pctV(mixThreshold)})',
    );

    if (sim >= mixThreshold) {
      await _handleCorrect();
    } else {
      await _handleWrong();
    }
  }

  String _pctV(double v) => '${(v * 100).toStringAsFixed(0)}%';

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  /// Normalizes a color name to a canonical key so Arabic and English match
  /// e.g. "أصفر" == "yellow".
  String _canonColor(String name) {
    final n = name.trim().toLowerCase();

    const map = {
      'أصفر': 'yellow',
      'اصفر': 'yellow',
      'yellow': 'yellow',
      'أحمر': 'red',
      'احمر': 'red',
      'red': 'red',
      'أزرق': 'blue',
      'ازرق': 'blue',
      'blue': 'blue',
      'أخضر': 'green',
      'اخضر': 'green',
      'green': 'green',
      'أبيض': 'white',
      'ابيض': 'white',
      'white': 'white',
      'أسود': 'black',
      'اسود': 'black',
      'black': 'black',
      'برتقالي': 'orange',
      'orange': 'orange',
      'بنفسجي': 'purple',
      'purple': 'purple',
    };

    return map[n] ?? n;
  }

  bool _sameColorName(String a, String b) {
    if (a.trim().isEmpty || b.trim().isEmpty) return false;
    return _canonColor(a) == _canonColor(b);
  }

  Future<void> _handleCorrect() async {
    // Step B — mark attempt completed + log COMPLETED level event
    try {
      await _service.updateLevelAttempt(
        attemptId: _currentAttemptId,
        completed: true,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'COMPLETED',
      );
    } catch (e) {
      debugPrint('CORRECT FLOW ERROR: $e');
    }

    emit(ColorLabChallengeResult(isCorrect: true, snapshot: _snapshot()));
  }

  Future<void> _handleWrong() async {
    // Step C — mark attempt failed, log FAILED, create new attempt, log RETRIED
    try {
      await _service.updateLevelAttempt(
        attemptId: _currentAttemptId,
        completed: false,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FAILED',
      );

      _attemptNumber += 1;

      _currentAttemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level.id,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'RETRIED',
      );
    } catch (e) {
      debugPrint('WRONG FLOW ERROR: $e');
    }

    emit(ColorLabChallengeResult(isCorrect: false, snapshot: _snapshot()));
  }

  // ===================== NEXT =====================

  /// Called by the screen after showing feedback.
  Future<void> nextChallenge() async {
    // If the last result was wrong, just let the child retry the same challenge.
    final result = state;
    final wasWrong = result is ColorLabChallengeResult && !result.isCorrect;

    if (wasWrong) {
      _selected.clear();
      _undosUsed = 0;

      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      _emitLoaded();
      return;
    }

    // Correct → advance.
    _selected.clear();
    _undosUsed = 0;
    _attemptNumber = 1;

    final isLastChallenge =
        _currentChallengeIndex >= _level.challenges.length - 1;
    final isLastLevel = _currentLevelIndex >= _levels.length - 1;

    if (isLastChallenge && isLastLevel) {
      await _completeActivity();
      emit(const ColorLabLevelComplete());
      return;
    }

    if (isLastChallenge) {
      // Move to next level
      _currentLevelIndex += 1;
      _currentChallengeIndex = 0;

      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      try {
        _currentAttemptId = await _service.createLevelAttempt(
          attemptNumber: 1,
          activitySessionId: activitySessionId,
          levelId: _level.id,
        );

        await _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'STARTED',
        );
      } catch (e) {
        debugPrint('NEXT LEVEL ERROR: $e');
      }

      _emitLoaded();
      return;
    }

    // Next challenge in same level
    _currentChallengeIndex += 1;

    await _saveProgress(
      levelIndex: _currentLevelIndex,
      challengeIndex: _currentChallengeIndex,
    );

    try {
      _currentAttemptId = await _service.createLevelAttempt(
        attemptNumber: 1,
        activitySessionId: activitySessionId,
        levelId: _level.id,
      );
    } catch (e) {
      debugPrint('NEXT CHALLENGE ATTEMPT ERROR: $e');
    }

    _emitLoaded();
  }

  Future<void> _completeActivity() async {
    if (_activityCompleted) return;
    _activityCompleted = true;

    try {
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );

      await _service.completeActivitySession(activitySessionId);
      await _clearSavedProgress();
    } catch (e) {
      debugPrint('COMPLETE ACTIVITY ERROR: $e');
    }
  }

  // ===================== EXIT =====================

  /// Step D — called when leaving the game without completing.
  Future<void> logExitIfNotCompleted() async {
    if (_activityCompleted) return;

    try {
      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (e) {
      debugPrint('EXIT EVENT ERROR: $e');
    }
  }

  // ===================== HELPERS =====================

  void _emitLoaded() {
    emit(
      ColorLabLoaded(
        level: _level,
        currentChallengeIndex: _currentChallengeIndex,
        selectedColors: List.unmodifiable(_selected),
        currentAttemptId: _currentAttemptId,
        attemptNumber: _attemptNumber,
        elapsed: _elapsed,
        undosUsed: _undosUsed,
        maxUndos: _maxUndos,
      ),
    );
  }

  ColorLabLoaded _snapshot() {
    return ColorLabLoaded(
      level: _level,
      currentChallengeIndex: _currentChallengeIndex,
      selectedColors: List.unmodifiable(_selected),
      currentAttemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      elapsed: _elapsed,
      undosUsed: _undosUsed,
      maxUndos: _maxUndos,
    );
  }

  /// Mix selected colors by averaging RGB.
  List<int> _mixSelectedColors() {
    if (_selected.isEmpty) return [255, 255, 255];
    return ColorMixer.mix(_selected);
  }

  /// Returns similarity 0..1 between two RGB colors.
  double _colorSimilarity(List<int> a, List<int> b) {
    final dr = (a[0] - b[0]).toDouble();
    final dg = (a[1] - b[1]).toDouble();
    final db = (a[2] - b[2]).toDouble();

    final distance = math.sqrt(dr * dr + dg * dg + db * db);

    // Max possible Euclidean distance between two RGB colors.
    final maxDistance = math.sqrt(255.0 * 255.0 * 3);

    final normalized = distance / maxDistance;
    return (1.0 - normalized).clamp(0.0, 1.0);
  }
}

class _ColorLabSavedProgress {
  final int levelIndex;
  final int challengeIndex;

  const _ColorLabSavedProgress({
    required this.levelIndex,
    required this.challengeIndex,
  });
}

class _ColorLabStartPosition {
  final int levelIndex;
  final int challengeIndex;

  const _ColorLabStartPosition({
    required this.levelIndex,
    required this.challengeIndex,
  });
}