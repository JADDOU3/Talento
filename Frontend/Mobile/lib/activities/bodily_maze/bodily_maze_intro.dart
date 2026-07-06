import 'package:flutter/material.dart';

import '../../shared/layout/animated_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'bodily_maze_game_screen.dart';

/// Entry point for the Bodily Maze activity. Same pattern as Color Lab.
///
/// Receives the already-resolved context: activityId, activitySessionId,
/// childId, sessionId, startLevelId, startLevelNumber.
class BodilyMazeIntro extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const BodilyMazeIntro({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });

  void _openGame(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BodilyMazeGameScreen(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
          startLevelId: startLevelId,
          startLevelNumber: startLevelNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      background: const AnimatedBackground(child: SizedBox.expand()),
      mascotAssetPath: 'assets/images/template_mascot.png',
      startButtonText: 'ابدأ المغامرة',
      replayButtonText: 'اسمع الشرح مرة أخرى',
      onStartPressed: () => _openGame(context),
      onReplayPressed: () => _openGame(context),
    );
  }
}
