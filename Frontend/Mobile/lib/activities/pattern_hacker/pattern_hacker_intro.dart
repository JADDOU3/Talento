import 'package:flutter/material.dart';

import '../../shared/layout/animated_background.dart';
import '../../services/activities/pattern_hacker_service.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'pattern_hacker_game_screen.dart';

class PatternHackerIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const PatternHackerIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<PatternHackerIntro> createState() => _PatternHackerIntroState();
}

class _PatternHackerIntroState extends State<PatternHackerIntro> {
  final PatternHackerService _patternHackerService = PatternHackerService();
  final RoadmapService _roadmapService = RoadmapService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('PATTERN HACKER: start pressed');
      print('PATTERN HACKER: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('PATTERN HACKER: resolved childId = ${resolvedData.childId}');
      print('PATTERN HACKER: resolved sessionId = ${resolvedData.sessionId}');
      print('PATTERN HACKER: resolved kitId = ${resolvedData.kitId}');
      print('PATTERN HACKER: resolved activityId = ${resolvedData.activityId}');

      int? startLevelId;
      int startLevelNumber = widget.initialLevelNumber <= 0
          ? 1
          : widget.initialLevelNumber;

      print('PATTERN HACKER: loading activity progress...');

      final progress = await _roadmapService.getActivityProgress(
        activityId: resolvedData.activityId,
      );

      if (progress == null) {
        print('PATTERN HACKER: no progress found, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.completed) {
        print('PATTERN HACKER: activity completed, replay starts from level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.hasValidCurrentLevel) {
        startLevelId = progress.currentLevelId;
        startLevelNumber = progress.currentLevelNumber <= 0
            ? 1
            : progress.currentLevelNumber;

        print('PATTERN HACKER: resume from levelId = $startLevelId');
        print('PATTERN HACKER: resume from levelNumber = $startLevelNumber');
      } else {
        print('PATTERN HACKER: invalid progress level, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      }

      print('PATTERN HACKER: creating activity session...');

      final activitySessionId =
      await _patternHackerService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print('PATTERN HACKER: created activitySessionId = $activitySessionId');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatternHackerGameScreen(
            activityId: resolvedData.activityId,
            activitySessionId: activitySessionId,
            childId: resolvedData.childId,
            sessionId: resolvedData.sessionId,
            initialLevelNumber: startLevelNumber,
            startLevelId: startLevelId,
          ),
        ),
      );
    } catch (error) {
      print('PATTERN HACKER START ERROR: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر بدء النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isPreparing = false;
      });
    }
  }

  Future<_PatternHackerResolvedData> _resolveGameData() async {
    final childId =
        widget.childId ?? await _patternHackerService.getSelectedChildId();

    final sessionIdFromWidget = widget.sessionId;
    final kitIdFromWidget = widget.kitId;
    final activityIdFromWidget = widget.activityId;

    if (kitIdFromWidget == null || kitIdFromWidget == 0) {
      throw Exception('Kit id was not provided.');
    }

    if (activityIdFromWidget == null || activityIdFromWidget == 0) {
      throw Exception('Activity id was not provided.');
    }

    if (sessionIdFromWidget != null && sessionIdFromWidget != 0) {
      return _PatternHackerResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print('PATTERN HACKER: getting latest session for childId = $childId');

    final latestSession =
    await _patternHackerService.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _patternHackerService.readSessionId(latestSession);
      print('PATTERN HACKER: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print('PATTERN HACKER: no latest session, creating new session...');
      sessionId = await _patternHackerService.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );
      print('PATTERN HACKER: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _PatternHackerResolvedData(
      childId: childId,
      sessionId: sessionId,
      kitId: kitIdFromWidget,
      activityId: activityIdFromWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ActivityIntroTemplate(
          background: const AnimatedBackground(
            child: SizedBox.expand(),
          ),
          mascotAssetPath: 'assets/images/template_mascot.png',
          onStartPressed: _prepareAndStartGame,
          onReplayPressed: _prepareAndStartGame,
        ),
        if (_isPreparing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.18),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class _PatternHackerResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _PatternHackerResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}