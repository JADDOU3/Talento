import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/layout/animated_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import 'tower_builder_build_screen.dart';

class TowerBuilderIntro extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const TowerBuilderIntro({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });

  void _openBuildScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TowerBuilderCubit(),
          child: TowerBuilderBuildScreen(
            activityId: activityId,
            activitySessionId: activitySessionId,
            childId: childId,
            sessionId: sessionId,
            startLevelId: startLevelId,
            startLevelNumber: startLevelNumber,
          ),
        ),
      ),
    );
  }

  void _openReplay(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TowerBuilderCubit(),
          child: TowerBuilderBuildScreen(
            activityId: activityId,
            activitySessionId: activitySessionId,
            childId: childId,
            sessionId: sessionId,
            startLevelId: null,
            startLevelNumber: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      background: const AnimatedBackground(
        child: SizedBox.expand(),
      ),
      mascotAssetPath: 'assets/images/template_mascot.png',
      onStartPressed: () {
        _openBuildScreen(context);
      },
      onReplayPressed: () {
        _openReplay(context);
      },
    );
  }
}