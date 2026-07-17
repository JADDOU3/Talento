import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/layout/animated_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import 'shape_creator_build_screen.dart';

class ShapeCreatorIntro extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const ShapeCreatorIntro({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });

  void _openBuildScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ShapeCreatorCubit(),
          child: ShapeCreatorBuildScreen(
            activityId: activityId,
            activitySessionId: activitySessionId,
            childId: childId,
            sessionId: sessionId,
            startLevelId: startLevelId,
            initialLevelNumber: startLevelNumber,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      activityId: activityId,
      background: const AnimatedBackground(
        child: SizedBox.expand(),
      ),
      mascotAssetPath: 'assets/images/template_mascot.png',
      onStartPressed: () {
        _openBuildScreen(context);
      },
      onReplayPressed: () {
        _openBuildScreen(context);
      },
    );
  }
}