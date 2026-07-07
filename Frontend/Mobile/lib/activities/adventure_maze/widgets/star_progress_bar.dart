import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../maze_engine/physics/star_painter.dart';

/// Row of stars above the maze — one per challenge, in the order the
/// backend returned. Uses the exact same star shape as in-game (via
/// [StarPainter]). Pass [starColors] straight from the level config
/// (config.starColors) so the bar always matches the in-game star colors.
/// Muted grey by default; fills in with its real color + glow once its
/// challengeId is added to [collectedChallengeIds].
class StarProgressBar extends StatelessWidget {
  final List<int> orderedChallengeIds;
  final Set<int> collectedChallengeIds;
  final Map<int, Color> starColors;

  const StarProgressBar({
    super.key,
    required this.orderedChallengeIds,
    required this.collectedChallengeIds,
    required this.starColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: orderedChallengeIds.map((cid) {
          final collected = collectedChallengeIds.contains(cid);
          final color = starColors[cid] ?? const Color(0xFFFFD600);
          return _AnimatedStar(collected: collected, color: color);
        }).toList(),
      ),
    );
  }
}

class _AnimatedStar extends StatelessWidget {
  final bool collected;
  final Color color;

  const _AnimatedStar({required this.collected, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      width: collected ? 34 : 28,
      height: collected ? 34 : 28,
      child: CustomPaint(
        painter: _StarIconPainter(collected: collected, color: color),
      ),
    );
  }
}

class _StarIconPainter extends CustomPainter {
  final bool collected;
  final Color color;

  _StarIconPainter({required this.collected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    StarPainter.paintStar(
      canvas,
      center,
      outerR,
      collected ? color : AppColors.border,
      withGlow: collected,
    );
  }

  @override
  bool shouldRepaint(covariant _StarIconPainter oldDelegate) {
    return oldDelegate.collected != collected || oldDelegate.color != color;
  }
}