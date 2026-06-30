import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class KitLibraryHeader extends StatelessWidget {
  final bool isChildMode;

  const KitLibraryHeader({
    super.key,
    required this.isChildMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 118,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFDFF6F3),
            Color(0xFFF7FFFE),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.transparent,
                      const Color(0xFFCCF1EC).withValues(alpha: 0.18),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  const _HeaderWordCloud(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isChildMode ? 'صناديقي' : 'مكتبة الصناديق',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: const Color(0xFF087C78),
                              fontSize: 23.5,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isChildMode
                                ? 'كل الصناديق المتاحة لطفلك في مكان واحد'
                                : 'استكشف صناديق تعليمية ممتعة لتنمية مهارات طفلك',
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderWordCloud extends StatelessWidget {
  const _HeaderWordCloud();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 26,
            child: _HeaderFloatingTag(
              text: 'متعة',
              color: AppColors.pink,
              width: 54,
              height: 26,
            ),
          ),
          Positioned(
            top: 26,
            left: 0,
            child: Transform.rotate(
              angle: -0.06,
              child: _HeaderFloatingTag(
                text: 'تعلم',
                color: AppColors.yellow,
                width: 52,
                height: 26,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 22,
            child: _HeaderFloatingTag(
              text: 'اكتشاف',
              color: AppColors.primary,
              width: 62,
              height: 27,
            ),
          ),
          Positioned(
            top: -2,
            left: 10,
            child: _headerSparkle(AppColors.yellow, 10),
          ),
          Positioned(
            top: 10,
            left: 82,
            child: _headerSparkle(AppColors.pink, 8),
          ),
          Positioned(
            top: 39,
            left: 62,
            child: _tinyBubble(AppColors.primary, 5),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: _tinyBubble(AppColors.pink, 4),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: _headerSparkle(AppColors.yellow, 9),
          ),
          Positioned(
            bottom: 10,
            left: 86,
            child: _tinyBubble(AppColors.secondary, 5),
          ),
        ],
      ),
    );
  }

  Widget _headerSparkle(Color color, double size) {
    return Icon(
      Icons.star_rounded,
      color: color.withValues(alpha: 0.82),
      size: size,
    );
  }

  Widget _tinyBubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeaderFloatingTag extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;

  const _HeaderFloatingTag({
    required this.text,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        color == AppColors.yellow ? const Color(0xFFD59A00) : color;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontSize: 10.8,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}
