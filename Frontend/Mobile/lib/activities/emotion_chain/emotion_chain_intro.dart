import 'package:flutter/material.dart';

import '../../services/activities/emotion_chain_service.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'emotion_chain_video_screen.dart';
import '../../shared/layout/animated_background.dart';

/// Entry point for the Emotion Chain activity.
/// Resolves the child/session context, opens an activity session, then
/// navigates to the video screen.
class EmotionChainIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const EmotionChainIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<EmotionChainIntro> createState() => _EmotionChainIntroState();
}

class _EmotionChainIntroState extends State<EmotionChainIntro> {
  final EmotionChainService _service = EmotionChainService();
  bool _isPreparing = false;

  Future<void> _start() async {
    if (_isPreparing) return;
    setState(() => _isPreparing = true);

    try {
      final data = await _resolveContext();

      final activitySessionId = await _service.createActivitySession(
        activityId: data.activityId,
        sessionId: data.sessionId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmotionChainVideoScreen(
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
            'تعذّر بدء النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  Future<_ResolvedContext> _resolveContext() async {
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
      return _ResolvedContext(
        childId: childId,
        sessionId: widget.sessionId!,
        activityId: activityId,
      );
    }

    final latestSession = await _service.getLatestSessionForChild(childId);
    int sessionId = 0;
    if (latestSession != null) {
      sessionId = _service.readSessionId(latestSession);
    }
    if (sessionId == 0) {
      sessionId = await _service.createSession(childId: childId, kitId: kitId);
    }
    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _ResolvedContext(
      childId: childId,
      sessionId: sessionId,
      activityId: activityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ActivityIntroTemplate(
          background: const AnimatedBackground(child: SizedBox.expand()),
          mascotAssetPath: 'assets/images/template_mascot.png',
          startButtonText: 'ابدأ القصة',
          onStartPressed: _start,
          onReplayPressed: _start,
        ),
        if (_isPreparing)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _ResolvedContext {
  final int childId;
  final int sessionId;
  final int activityId;

  const _ResolvedContext({
    required this.childId,
    required this.sessionId,
    required this.activityId,
  });
}
