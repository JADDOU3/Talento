import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';

class ColorLabResultScreen extends StatelessWidget {
  final bool isCorrect;

  const ColorLabResultScreen({
    super.key,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: isCorrect
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}