import 'package:flutter/material.dart';

import '../../shared/layout/animated_background.dart';
import '../../services/activities/sound_tracker_service.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'sound_tracker_voice_screen.dart';

class SoundTrackerIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const SoundTrackerIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<SoundTrackerIntro> createState() => _SoundTrackerIntroState();
}

class _SoundTrackerIntroState extends State<SoundTrackerIntro> {
  final SoundTrackerService _soundTrackerService = SoundTrackerService();
  final RoadmapService _roadmapService = RoadmapService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('SOUND TRACKER: start pressed');
      print('SOUND TRACKER: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('SOUND TRACKER: resolved childId = ${resolvedData.childId}');
      print('SOUND TRACKER: resolved sessionId = ${resolvedData.sessionId}');
      print('SOUND TRACKER: resolved kitId = ${resolvedData.kitId}');
      print('SOUND TRACKER: resolved activityId = ${resolvedData.activityId}');

      int? startLevelId;
      int startLevelNumber = widget.initialLevelNumber <= 0
          ? 1
          : widget.initialLevelNumber;

      print('SOUND TRACKER: loading activity progress...');

      final progress = await _roadmapService.getActivityProgress(
        activityId: resolvedData.activityId,
      );

      if (progress == null) {
        print('SOUND TRACKER: no progress found, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.completed) {
        print('SOUND TRACKER: activity completed, replay starts from level 1');
        startLevelId = null;
        startLevelNumber = 1;
      } else if (progress.hasValidCurrentLevel) {
        startLevelId = progress.currentLevelId;
        startLevelNumber = progress.currentLevelNumber <= 0
            ? 1
            : progress.currentLevelNumber;

        print('SOUND TRACKER: resume from levelId = $startLevelId');
        print('SOUND TRACKER: resume from levelNumber = $startLevelNumber');
      } else {
        print('SOUND TRACKER: invalid progress level, fallback to level 1');
        startLevelId = null;
        startLevelNumber = 1;
      }

      print('SOUND TRACKER: creating activity session...');

      final activitySessionId =
      await _soundTrackerService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print(
        'SOUND TRACKER: created activitySessionId = $activitySessionId',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SoundTrackerVoiceScreen(
            activityId: resolvedData.activityId,
            activitySessionId: activitySessionId,
            childId: resolvedData.childId,
            sessionId: resolvedData.sessionId,
            startLevelId: startLevelId,
            startLevelNumber: startLevelNumber,
          ),
        ),
      );
    } catch (error) {
      print('SOUND TRACKER START ERROR: $error');

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

  Future<_SoundTrackerResolvedData> _resolveGameData() async {
    final childId = widget.childId ??
        await _soundTrackerService.getSelectedChildId();

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
      return _SoundTrackerResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print(
      'SOUND TRACKER: getting latest session for childId = $childId',
    );

    final latestSession =
    await _soundTrackerService.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _soundTrackerService.readSessionId(latestSession);
      print('SOUND TRACKER: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print('SOUND TRACKER: no latest session, creating new session...');

      sessionId = await _soundTrackerService.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );

      print('SOUND TRACKER: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _SoundTrackerResolvedData(
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

class _SoundTrackerResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _SoundTrackerResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}