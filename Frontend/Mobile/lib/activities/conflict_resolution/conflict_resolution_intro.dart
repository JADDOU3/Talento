import 'package:flutter/material.dart';

import '../../services/activities/conflict_resolution_service.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'conflict_resolution_video_screen.dart';

class ConflictResolutionIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const ConflictResolutionIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<ConflictResolutionIntro> createState() =>
      _ConflictResolutionIntroState();
}

class _ConflictResolutionIntroState extends State<ConflictResolutionIntro> {
  final ConflictResolutionService _service = ConflictResolutionService();
  final RoadmapService _roadmapService = RoadmapService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('CONFLICT RESOLUTION: start pressed');
      print('CONFLICT RESOLUTION: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('CONFLICT RESOLUTION: resolved childId = ${resolvedData.childId}');
      print('CONFLICT RESOLUTION: resolved sessionId = ${resolvedData.sessionId}');
      print('CONFLICT RESOLUTION: resolved kitId = ${resolvedData.kitId}');
      print('CONFLICT RESOLUTION: resolved activityId = ${resolvedData.activityId}');

      int? startLevelId;
      int startLevelNumber = widget.initialLevelNumber <= 0
          ? 1
          : widget.initialLevelNumber;

      print('CONFLICT RESOLUTION: loading activity progress...');

      final progress = await _roadmapService.getActivityProgress(
        activityId: resolvedData.activityId,
      );

      if (progress == null) {
        print('CONFLICT RESOLUTION: no progress found, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.completed) {
        print('CONFLICT RESOLUTION: activity completed, replay starts from level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.hasValidCurrentLevel) {
        startLevelId = progress.currentLevelId;
        startLevelNumber = progress.currentLevelNumber <= 0
            ? 1
            : progress.currentLevelNumber;

        print('CONFLICT RESOLUTION: resume from levelId = $startLevelId');
        print('CONFLICT RESOLUTION: resume from levelNumber = $startLevelNumber');
      } else {
        print('CONFLICT RESOLUTION: invalid progress level, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      }

      print('CONFLICT RESOLUTION: creating activity session...');

      final activitySessionId = await _service.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print('CONFLICT RESOLUTION: created activitySessionId = $activitySessionId');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConflictResolutionVideoScreen(
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
      print('CONFLICT RESOLUTION START ERROR: $error');

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

  Future<_ConflictResolutionResolvedData> _resolveGameData() async {
    final childId = widget.childId ?? await _service.getSelectedChildId();

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
      return _ConflictResolutionResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print('CONFLICT RESOLUTION: getting latest session for childId = $childId');

    final latestSession = await _service.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _service.readSessionId(latestSession);
      print('CONFLICT RESOLUTION: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print('CONFLICT RESOLUTION: no latest session, creating new session...');
      sessionId = await _service.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );
      print('CONFLICT RESOLUTION: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _ConflictResolutionResolvedData(
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
          background: const AppBackground(
            child: SizedBox.expand(),
          ),
          mascotAssetPath: 'assets/images/template_mascot.png',
          onStartPressed: _prepareAndStartGame,
          onReplayPressed: _prepareAndStartGame,
        ),
        if (_isPreparing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConflictResolutionResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _ConflictResolutionResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}