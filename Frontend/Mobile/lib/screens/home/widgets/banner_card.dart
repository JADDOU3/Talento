import 'package:flutter/material.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({super.key});

  static const String _mascotAsset = 'assets/images/mascot_challenge_success.png';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        height: 166,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEFFFFD),
              Color(0xFFF7FFFE),
              Color(0xFFFFF8ED),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFBDEDEA),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10A896).withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                top: -34,
                right: -26,
                child: _SoftCircle(
                  size: 105,
                  color: const Color(0xFF48C5DC).withOpacity(0.13),
                ),
              ),
              Positioned(
                bottom: -42,
                left: -28,
                child: _SoftCircle(
                  size: 125,
                  color: const Color(0xFFFFD36E).withOpacity(0.18),
                ),
              ),

              // Mascot on the left
              Positioned(
                bottom: 8,
                left: 10,
                child: SizedBox(
                  width: 118,
                  height: 140,
                  child: Image.asset(
                    _mascotAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10A896).withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.fromLTRB(128, 15, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'جاهز تبدأ الرحلة؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF086D66),
                          height: 1.18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'أضف بيانات طفلك لتبدأ سلسلة مغامرات لتنمية مهاراته',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF6B728F),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}