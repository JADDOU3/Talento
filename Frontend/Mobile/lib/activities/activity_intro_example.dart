import 'package:flutter/material.dart';

import '../shared/layout/app_background.dart';
import '../shared/widgets/activity_template/activity_intro_template.dart';

class ActivityIntroExample extends StatelessWidget {
  const ActivityIntroExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      background: const AppBackground(
        child: SizedBox.expand(),
      ),
      mascotAssetPath: 'assets/images/template_mascot.png',
      onStartPressed: () {
        debugPrint('Start activity pressed');
      },
      onReplayPressed: () {
        debugPrint('Replay explanation pressed');
      },
    );
  }
}