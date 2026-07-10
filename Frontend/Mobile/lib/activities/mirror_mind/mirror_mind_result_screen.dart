import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'mirror_mind_game_screen.dart';

class MirrorMindResultScreen extends StatelessWidget {
  final Duration elapsed;
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int initialLevelNumber;

  const MirrorMindResultScreen({
    super.key,
    required this.elapsed,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.initialLevelNumber = 1,
  });

  void _goToRoadmap(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _replayActivity(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MirrorMindGameScreen(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
          initialLevelNumber: initialLevelNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: ActivityFeedbackType.correct,

        // الزر الرئيسي الموحّد "التالي"
        onPrimaryPressed: () => _goToRoadmap(context),

        // الإجراء الإضافي الموحّد "إعادة النشاط"
        onSecondaryPressed: () => _replayActivity(context),
      ),
    );
  }
}