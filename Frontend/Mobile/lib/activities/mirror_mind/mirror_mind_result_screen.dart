import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/layout/app_background.dart';
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.yellow.withOpacity(0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🎉',
                        style: TextStyle(fontSize: 54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'أحسنت!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DGAgnadeen',
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'لقد أصبحت خبير انعكاسات!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 21,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      'الوقت: ${_formatDuration(elapsed)}',
                      style: const TextStyle(
                        fontFamily: 'ArialRounded',
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'العب مرة أخرى',
                        style: TextStyle(
                          fontFamily: 'DGAgnadeen',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                              (route) => route.isFirst,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'العودة للخريطة',
                        style: TextStyle(
                          fontFamily: 'DGAgnadeen',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}