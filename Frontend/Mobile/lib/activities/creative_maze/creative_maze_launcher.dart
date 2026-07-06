import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/config/api_constants.dart';
import '../../services/activities/creative_maze_service.dart';
import '../../services/auth/auth_api_client.dart';
import 'creative_maze_intro.dart';

class CreativeMazeLauncher extends StatefulWidget {
  final int activityId;
  final int kitId;
  final int childId;
  final int? initialLevelNumber;

  const CreativeMazeLauncher({
    super.key,
    required this.activityId,
    required this.kitId,
    required this.childId,
    this.initialLevelNumber,
  });

  @override
  State<CreativeMazeLauncher> createState() => _CreativeMazeLauncherState();
}

class _CreativeMazeLauncherState extends State<CreativeMazeLauncher> {
  final CreativeMazeService _service = CreativeMazeService();
  final AuthApiClient _apiClient = AuthApiClient();

  @override
  void initState() {
    super.initState();
    _prepareAndOpenIntro();
  }

  Future<void> _prepareAndOpenIntro() async {
    try {
      final session = await _service.getLatestSessionForChild(widget.childId);

      if (session == null) {
        throw Exception('No active session was found for this child.');
      }

      final sessionId = _service.readSessionId(session);

      final requestedLevelNumber = widget.initialLevelNumber;

      int? startLevelId;
      int startLevelNumber =
      requestedLevelNumber != null && requestedLevelNumber > 0
          ? requestedLevelNumber
          : 1;

      // مهم:
      // إذا المستوى جاي من الرودماب، لا نخلي progress endpoint يغيّره.
      // لأنه المتاهات مقسمة كارد لكل level.
      if (requestedLevelNumber == null) {
        try {
          final progressResp = await _apiClient.get(
            Uri.parse(ApiConstants.roadmapProgress(widget.activityId)),
          );

          if (progressResp.statusCode >= 200 && progressResp.statusCode < 300) {
            final progress = jsonDecode(progressResp.body);

            if (progress is Map && progress['completed'] != true) {
              startLevelId = _asIntOrNull(progress['currentLevelId']);
              startLevelNumber =
                  _asIntOrNull(progress['currentLevelNumber']) ?? startLevelNumber;
            }
          }
        } catch (_) {}
      }

      final activitySessionId = await _service.createActivitySession(
        activityId: widget.activityId,
        sessionId: sessionId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreativeMazeIntro(
            activityId: widget.activityId,
            activitySessionId: activitySessionId,
            childId: widget.childId,
            sessionId: sessionId,
            startLevelId: startLevelId,
            startLevelNumber: startLevelNumber <= 0 ? 1 : startLevelNumber,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح النشاط: $error',
            textDirection: TextDirection.rtl,
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}