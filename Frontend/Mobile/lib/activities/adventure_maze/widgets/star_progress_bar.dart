import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Row of stars above the maze — one per challenge, in the order the
/// backend returned. Grey by default; each star fills with Talento's brand
/// gold when its challengeId is added to [collectedChallengeIds].
class StarProgressBar extends StatelessWidget {
  final List<int> orderedChallengeIds;
  final Set<int> collectedChallengeIds;

  const StarProgressBar({
    super.key,
    required this.orderedChallengeIds,
    required this.collectedChallengeIds,
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
          return _AnimatedStar(collected: collected);
        }).toList(),
      ),
    );
  }
}

class _AnimatedStar extends StatelessWidget {
  final bool collected;
  const _AnimatedStar({required this.collected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      width: collected ? 34 : 28,
      height: collected ? 34 : 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (collected)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.yellow.withValues(alpha: 0.4),
                    AppColors.yellow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          Icon(
            collected ? Icons.star_rounded : Icons.star_outline_rounded,
            size: collected ? 30 : 26,
            color: collected
                ? AppColors.yellow
                : AppColors.border,
          ),
        ],
      ),
    );
  }
}
