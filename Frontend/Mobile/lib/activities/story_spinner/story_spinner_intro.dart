import 'package:flutter/material.dart';

import '../../services/activities/story_spinner_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'story_spinner_wheel_screen.dart';

class StorySpinnerIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const StorySpinnerIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<StorySpinnerIntro> createState() => _StorySpinnerIntroState();
}

class _StorySpinnerIntroState extends State<StorySpinnerIntro> {
  final StorySpinnerService _service = StorySpinnerService();

  bool _isPreparing = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      final data = await _resolveGameData();

      final activitySessionId = await _service.createActivitySession(
        activityId: data.activityId,
        sessionId: data.sessionId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StorySpinnerWheelScreen(
            activityId: data.activityId,
            activitySessionId: activitySessionId,
            childId: data.childId,
            sessionId: data.sessionId,
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

  Future<_StorySpinnerResolvedData> _resolveGameData() async {
    final childId = widget.childId ?? await _service.getSelectedChildId();
    final kitId = widget.kitId;
    final activityId = widget.activityId;

    if (kitId == null || kitId == 0) {
      throw Exception('Kit id was not provided.');
    }

    if (activityId == null || activityId == 0) {
      throw Exception('Activity id was not provided.');
    }

    if (widget.sessionId != null && widget.sessionId != 0) {
      return _StorySpinnerResolvedData(
        childId: childId,
        sessionId: widget.sessionId!,
        kitId: kitId,
        activityId: activityId,
      );
    }

    final latestSession = await _service.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _service.readSessionId(latestSession);
    }

    if (sessionId == 0) {
      sessionId = await _service.createSession(
        childId: childId,
        kitId: kitId,
      );
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _StorySpinnerResolvedData(
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
          startButtonText: 'ابدأ القصة',
          replayButtonText: 'اسمع الشرح مرة أخرى',
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

class _StorySpinnerResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _StorySpinnerResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}