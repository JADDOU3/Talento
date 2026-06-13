import 'package:flutter/material.dart';

import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'color_lab_game_screen.dart';

/// Entry point for the Color Lab activity.
/// Follows the exact same pattern as activity_intro_example.dart.
///
/// Receives the resolved game context (already fetched before this screen):
/// activityId, activitySessionId, childId, sessionId.
class ColorLabIntro extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const ColorLabIntro({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  void _openGame(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ColorLabGameScreen(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      background: const AppBackground(child: SizedBox.expand()),
      mascotAssetPath: 'assets/images/template_mascot.png',
      startButtonText: 'ابدأ المغامرة',
      replayButtonText: 'اسمع الشرح مرة أخرى',
      onStartPressed: () => _openGame(context),
      onReplayPressed: () {
        // Replay the spoken explanation (voice line handled elsewhere).
        // For now, re-opening the game acts as replay entry.
        _openGame(context);
      },
    );
  }
}
