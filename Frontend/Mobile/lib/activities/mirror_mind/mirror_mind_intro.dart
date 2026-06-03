import 'package:flutter/material.dart';

import '../../services/activities/mirror_mind_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'mirror_mind_game_screen.dart';

class MirrorMindIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const MirrorMindIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<MirrorMindIntro> createState() => _MirrorMindIntroState();
}

class _MirrorMindIntroState extends State<MirrorMindIntro> {
  final MirrorMindService _mirrorMindService = MirrorMindService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      final resolvedData = await _resolveGameData();

      final activitySessionId =
      await _mirrorMindService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MirrorMindGameScreen(
            activityId: resolvedData.activityId,
            activitySessionId: activitySessionId,
            childId: resolvedData.childId,
            sessionId: resolvedData.sessionId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر بدء النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
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
    final childId = widget.childId ?? await _mirrorMindService.getSelectedChildId();

    final sessionIdFromWidget = widget.sessionId;
    final kitIdFromWidget = widget.kitId;
    final activityIdFromWidget = widget.activityId;

    if (sessionIdFromWidget != null && activityIdFromWidget != null) {
      return _MirrorMindResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget ?? 0,
        activityId: activityIdFromWidget,
      );
    }

    final latestSession =
    await _mirrorMindService.getLatestSessionForChild(childId);

    if (latestSession == null) {
      throw Exception('No latest session was found for the selected child.');
    }

    final sessionId = sessionIdFromWidget ??
        _mirrorMindService.readSessionId(latestSession);

    if (sessionId == 0) {
      throw Exception('Session id was not found.');
    }

    final kitId = kitIdFromWidget ?? _mirrorMindService.readKitId(latestSession);

    if (kitId == 0) {
      throw Exception('Kit id was not found.');
    }

    if (activityIdFromWidget != null) {
      return _MirrorMindResolvedData(
        childId: childId,
        sessionId: sessionId,
        kitId: kitId,
        activityId: activityIdFromWidget,
      );
    }

    final roadmapActivities = await _mirrorMindService.getRoadmapActivities(
      kitId: kitId,
      childId: childId,
    );

    final currentActivity =
    _mirrorMindService.findCurrentActivity(roadmapActivities);

    if (currentActivity == null) {
      throw Exception('No current activity was found.');
    }

    final activityId = _mirrorMindService.readActivityId(currentActivity);

    if (activityId == 0) {
      throw Exception('Activity id was not found.');
    }

    return _MirrorMindResolvedData(
      childId: childId,
      sessionId: sessionId,
      kitId: kitId,
      activityId: activityId,
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