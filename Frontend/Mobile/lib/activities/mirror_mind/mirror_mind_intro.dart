import 'package:flutter/material.dart';

import '../../services/activities/mirror_mind_service.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'mirror_mind_game_screen.dart';

class MirrorMindIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const MirrorMindIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<MirrorMindIntro> createState() => _MirrorMindIntroState();
}

class _MirrorMindIntroState extends State<MirrorMindIntro> {
  final MirrorMindService _mirrorMindService = MirrorMindService();
  final RoadmapService _roadmapService = RoadmapService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('MIRROR MIND: start pressed');
      print('MIRROR MIND: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('MIRROR MIND: resolved childId = ${resolvedData.childId}');
      print('MIRROR MIND: resolved sessionId = ${resolvedData.sessionId}');
      print('MIRROR MIND: resolved kitId = ${resolvedData.kitId}');
      print('MIRROR MIND: resolved activityId = ${resolvedData.activityId}');

      int? startLevelId;
      int startLevelNumber = widget.initialLevelNumber <= 0
          ? 1
          : widget.initialLevelNumber;

      print('MIRROR MIND: loading activity progress...');

      final progress = await _roadmapService.getActivityProgress(
        activityId: resolvedData.activityId,
      );

      if (progress == null) {
        print('MIRROR MIND: no progress found, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.completed) {
        print('MIRROR MIND: activity completed, replay starts from level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.hasValidCurrentLevel) {
        startLevelId = progress.currentLevelId;
        startLevelNumber = progress.currentLevelNumber <= 0
            ? 1
            : progress.currentLevelNumber;

        print('MIRROR MIND: resume from levelId = $startLevelId');
        print('MIRROR MIND: resume from levelNumber = $startLevelNumber');
      } else {
        print('MIRROR MIND: invalid progress level, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      }

      print('MIRROR MIND: creating activity session...');

      final activitySessionId = await _mirrorMindService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print('MIRROR MIND: created activitySessionId = $activitySessionId');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MirrorMindGameScreen(
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
      print('MIRROR MIND START ERROR: $error');

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

  Future<_MirrorMindResolvedData> _resolveGameData() async {
    final childId =
        widget.childId ?? await _mirrorMindService.getSelectedChildId();

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
      return _MirrorMindResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print('MIRROR MIND: getting latest session for childId = $childId');

    final latestSession =
    await _mirrorMindService.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _mirrorMindService.readSessionId(latestSession);
      print('MIRROR MIND: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print('MIRROR MIND: no latest session, creating new session...');
      sessionId = await _mirrorMindService.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );
      print('MIRROR MIND: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _MirrorMindResolvedData(
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

class _MirrorMindResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _MirrorMindResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}