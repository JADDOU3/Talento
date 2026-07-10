import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'pattern_hacker_game_screen.dart';

class PatternHackerResultScreen extends StatelessWidget {
  final Duration elapsed;
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const PatternHackerResultScreen({
    super.key,
    required this.elapsed,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  void _goToRoadmap(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _replayActivity(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PatternHackerGameScreen(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
          initialLevelNumber: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: ActivityFeedbackType.correct,

        // زر "التالي" يرجع للخريطة.
        onPrimaryPressed: () {
          _goToRoadmap(context);
        },

        // زر "إعادة النشاط" يبدأ اللعبة من أول مستوى.
        onSecondaryPressed: () {
          _replayActivity(context);
        },
      ),
    );
  }
}