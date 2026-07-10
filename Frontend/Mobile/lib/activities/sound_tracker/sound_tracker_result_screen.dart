import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';

class SoundTrackerResultScreen extends StatelessWidget {
  final bool isCorrect;
  final int levelNumber;
  final int totalLevels;
  final bool isLastLevel;
  final String message;
  final VoidCallback onRetryPressed;
  final VoidCallback onContinuePressed;

  const SoundTrackerResultScreen({
    super.key,
    required this.isCorrect,
    required this.levelNumber,
    required this.totalLevels,
    required this.isLastLevel,
    required this.message,
    required this.onRetryPressed,
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: isCorrect
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,
        onPrimaryPressed: isCorrect
            ? onContinuePressed
            : onRetryPressed,
      ),
    );
  }
}

class SoundTrackerActivityCompleteScreen extends StatefulWidget {
  final Future<void> Function(BuildContext context) onReplayPressed;
  final VoidCallback onBackToRoadmapPressed;

  const SoundTrackerActivityCompleteScreen({
    super.key,
    required this.onReplayPressed,
    required this.onBackToRoadmapPressed,
  });

  @override
  State<SoundTrackerActivityCompleteScreen> createState() =>
      _SoundTrackerActivityCompleteScreenState();
}

class _SoundTrackerActivityCompleteScreenState
    extends State<SoundTrackerActivityCompleteScreen> {
  bool _isRestarting = false;

  Future<void> _handleReplay() async {
    if (_isRestarting) return;

    setState(() {
      _isRestarting = true;
    });

    try {
      await widget.onReplayPressed(context);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isRestarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إعادة النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: ActivityFeedbackType.correct,

        // زر "التالي" يرجع إلى الخريطة.
        onPrimaryPressed: widget.onBackToRoadmapPressed,

        // زر "إعادة النشاط" يعيد النشاط من البداية.
        onSecondaryPressed: _handleReplay,
      ),
    );
  }
}