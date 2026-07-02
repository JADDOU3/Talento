import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FeatureCard extends StatelessWidget {
  final VoidCallback? onJoinMission;

  const FeatureCard({
    super.key,
    this.onJoinMission,
  });

  static const String _mascotAsset =
      'assets/images/community_header_mascot.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 235,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF06514E),
            Color(0xFF0C8F86),
            Color(0xFF16BFAE),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HeaderBackgroundPainter(),
            ),
          ),

          // Decorations around mascot - more organized
          const Positioned(
            left: 30,
            top: 80,
            child: _TinyStar(size: 20),
          ),
          const Positioned(
            left: 80,
            top: 10,
            child: _TinyStar(size: 15),
          ),
          const Positioned(
            left: 150,
            top: 50,
            child: _TinyStar(size: 12),
          ),

          const Positioned(
            left: 30,
            top: 40,
            child: _LoveBubble(),
          ),

          const Positioned(
            right: 130,
            top: 66,
            child: _HeartIcon(),
          ),

          // Mascot area
          Positioned(
            left: 18,
            top: 28,
            child: SizedBox(
              width: 145,
              height: 145,
              child: Transform.translate(
                offset: const Offset(10, 0),
                child: Transform.scale(
                  scale: 1.14,
                  alignment: Alignment.center,
                  child: Image.asset(
                    _mascotAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                '✨ مساحة الأبطال',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),

          // Text block
          Positioned(
            right: 22,
            top: 62,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مجتمع',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 33,
                      height: 0.92,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Transform.translate(
                    offset: const Offset(-40, 0),
                    child: Text(
                      'تالينتو...',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.yellow,
                        fontSize: 39,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: AppColors.black.withValues(alpha: 0.14),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 178,
                    child: Text(
                      'شارك إنجازك، شوف أفكار أصحابك، واكتشف قصصًا ملهمة كل يوم',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        height: 1.42,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button lower and more separated from mascot
          Positioned(
            left: 20,
            bottom: 38,
            child: _ChallengeButton(
              onTap: onJoinMission,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ChallengeButton({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFA6D93),
                Color(0xFFEC6886),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.78),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 9),
              Text(
                'تحدي اليوم',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.star_rounded,
                color: AppColors.white,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width + 10, 18),
      82,
      lightPaint,
    );

    canvas.drawCircle(
      const Offset(50, 170),
      95,
      lightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TinyStar extends StatelessWidget {
  final double size;

  const _TinyStar({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      color: AppColors.yellow,
      size: size,
    );
  }
}

class _HeartIcon extends StatelessWidget {
  const _HeartIcon();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Icon(
        Icons.favorite_rounded,
        color: AppColors.pink.withValues(alpha: 0.9),
        size: 17,
      ),
    );
  }
}
class _LoveBubble extends StatelessWidget {
  const _LoveBubble();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        width: 30,
        height: 25,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: 0.10,
          child: const Icon(
            Icons.favorite_rounded,
            color: AppColors.pink,
            size: 15,
          ),
        ),
      ),
    );
  }
}
