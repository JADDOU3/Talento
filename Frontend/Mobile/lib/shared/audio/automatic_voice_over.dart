import 'package:flutter/material.dart';

import '../../models/voice_over/voice_over_model.dart';
import 'voice_over_controller.dart';

enum AutomaticVoiceOverScope {
  intro,
  level,
  global,
}

class AutomaticVoiceOverRequest {
  final AutomaticVoiceOverScope scope;
  final int? activityId;
  final int? levelId;
  final GlobalVoiceOverType? globalType;

  const AutomaticVoiceOverRequest.intro({
    required int activityId,
  })  : scope = AutomaticVoiceOverScope.intro,
        activityId = activityId,
        levelId = null,
        globalType = null;

  const AutomaticVoiceOverRequest.level({
    required int activityId,
    required int levelId,
  })  : scope = AutomaticVoiceOverScope.level,
        activityId = activityId,
        levelId = levelId,
        globalType = null;

  const AutomaticVoiceOverRequest.global({
    required GlobalVoiceOverType type,
  })  : scope = AutomaticVoiceOverScope.global,
        activityId = null,
        levelId = null,
        globalType = type;

  bool isSameAs(AutomaticVoiceOverRequest other) {
    return scope == other.scope &&
        activityId == other.activityId &&
        levelId == other.levelId &&
        globalType == other.globalType;
  }
}

class AutomaticVoiceOver extends StatefulWidget {
  final AutomaticVoiceOverRequest request;
  final Widget child;

  const AutomaticVoiceOver({
    super.key,
    required this.request,
    required this.child,
  });

  @override
  State<AutomaticVoiceOver> createState() =>
      _AutomaticVoiceOverState();
}

class _AutomaticVoiceOverState extends State<AutomaticVoiceOver> {
  final VoiceOverController _controller = VoiceOverController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _play();
    });
  }

  @override
  void didUpdateWidget(covariant AutomaticVoiceOver oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.request.isSameAs(widget.request)) {
      _play();
    }
  }

  Future<void> _play() async {
    final request = widget.request;

    switch (request.scope) {
      case AutomaticVoiceOverScope.intro:
        await _controller.playIntro(
          activityId: request.activityId!,
        );
        break;

      case AutomaticVoiceOverScope.level:
        await _controller.playLevel(
          activityId: request.activityId!,
          levelId: request.levelId!,
        );
        break;

      case AutomaticVoiceOverScope.global:
        await _controller.playGlobal(
          request.globalType!,
        );
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
