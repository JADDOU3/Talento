import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/activities/creative_maze_service.dart';
import '../../services/auth/auth_api_client.dart';
import 'creative_maze_game_screen.dart';

/// Entry point for Creative Maze from the roadmap.
///
/// Runs the standard entry flow (identical to Bodily Maze):
///   1. selected child            -> childId
///   2. latest session for child  -> sessionId, kitId
///   3. roadmap progress          -> currentLevelId / completed (replay detect)
///   4. create activity session   -> activitySessionId
///   5. navigate to game screen
///
/// The roadmap card passes exactly one level (via levelFrom/levelTo filtering
/// upstream), so no level range handling is needed here.
class CreativeMazeIntro extends StatefulWidget {
  const CreativeMazeIntro({
    super.key,
    required this.activityId,
    this.initialLevelNumber,
  });

  final int activityId;
  final int? initialLevelNumber;

  @override
  State<CreativeMazeIntro> createState() => _CreativeMazeIntroState();
}

class _CreativeMazeIntroState extends State<CreativeMazeIntro> {
  final CreativeMazeService _service = CreativeMazeService();
  final AuthApiClient _apiClient = AuthApiClient();

  bool _starting = false;
  String? _error;

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      // 1. selected child
      final childId = await _service.getSelectedChildId();

      // 2. latest session -> sessionId, kitId
      final session = await _service.getLatestSessionForChild(childId);
      if (session == null) {
        throw Exception('No active session was found for this child.');
      }
      final sessionId = _service.readSessionId(session);

      // 3. roadmap progress (replay detection)
      int? startLevelId;
      int? startLevelNumber;
      try {
        final progressResp = await _apiClient.get(
          Uri.parse(ApiConstants.roadmapProgress(widget.activityId)),
        );
        if (progressResp.statusCode >= 200 && progressResp.statusCode < 300) {
          final p = jsonDecode(progressResp.body);
          final completed = p is Map && (p['completed'] == true);
          if (!completed && p is Map) {
            startLevelId = _asIntOrNull(p['currentLevelId']);
            startLevelNumber = _asIntOrNull(p['currentLevelNumber']);
          }
          // If completed, leave both null -> cubit starts from levels[0] (replay).
        }
      } catch (_) {
        // Non-fatal: fall back to first level if progress can't be read.
      }

      // 4. create activity session
      final activitySessionId = await _service.createActivitySession(
        activityId: widget.activityId,
        sessionId: sessionId,
      );

      if (!mounted) return;

      // 5. navigate to game
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreativeMazeGameScreen(
            activityId: widget.activityId,
            activitySessionId: activitySessionId,
            childId: childId,
            sessionId: sessionId,
            startLevelId: startLevelId,
            startLevelNumber: widget.initialLevelNumber ?? startLevelNumber,          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = error.toString();
      });
    }
  }

  int? _asIntOrNull(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9FAF6), Color(0xFFFFF9EA), Color(0xFFFFEEF3)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.explore_rounded,
                      size: 90, color: Color(0xFF10A896)),
                  const SizedBox(height: 20),
                  const Text(
                    'المتاهة الإبداعية',
                    style: TextStyle(
                      color: Color(0xFF123835),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ميلي الجهاز لتحريك الكرة ووصّليها لنقطة النهاية بأسرع وقت! '
                    'في أكثر من طريق صحيح — جرّبي.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF123835),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _starting ? null : _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10A896),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _starting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ابدأ اللعب',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
