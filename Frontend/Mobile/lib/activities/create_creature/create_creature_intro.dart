// lib/activities/create_creature/create_creature_intro.dart

import 'package:flutter/material.dart';

import '../../services/activities/create_creature_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'create_creature_face_screen.dart';

class CreateCreatureIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const CreateCreatureIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<CreateCreatureIntro> createState() => _CreateCreatureIntroState();
}

class _CreateCreatureIntroState extends State<CreateCreatureIntro> {
  final CreateCreatureService _createCreatureService = CreateCreatureService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('CREATE CREATURE: start pressed');
      print('CREATE CREATURE: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('CREATE CREATURE: resolved childId = ${resolvedData.childId}');
      print('CREATE CREATURE: resolved sessionId = ${resolvedData.sessionId}');
      print('CREATE CREATURE: resolved kitId = ${resolvedData.kitId}');
      print('CREATE CREATURE: resolved activityId = ${resolvedData.activityId}');

      print('CREATE CREATURE: creating activity session...');

      final activitySessionId = await _createCreatureService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print('CREATE CREATURE: created activitySessionId = $activitySessionId');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateCreatureFaceScreen(
            activityId: resolvedData.activityId,
            activitySessionId: activitySessionId,
            childId: resolvedData.childId,
            sessionId: resolvedData.sessionId,
          ),
        ),
      );
    } catch (error) {
      print('CREATE CREATURE START ERROR: $error');

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

  Future<_CreateCreatureResolvedData> _resolveGameData() async {
    final childId =
        widget.childId ?? await _createCreatureService.getSelectedChildId();

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
      return _CreateCreatureResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print('CREATE CREATURE: getting latest session for childId = $childId');

    final latestSession =
    await _createCreatureService.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _createCreatureService.readSessionId(latestSession);
      print('CREATE CREATURE: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print('CREATE CREATURE: no latest session, creating new session...');
      sessionId = await _createCreatureService.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );
      print('CREATE CREATURE: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _CreateCreatureResolvedData(
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

class _CreateCreatureResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _CreateCreatureResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}