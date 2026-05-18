import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEC6886).withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC6886).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFEC6886),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'أطلق العنان للإمكانات',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10A896),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'من خلال تقييم فصولهم الطبيعية، أنت تضمن تقديم أفضل دعم لهم اليوم',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B728F),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC6886),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('ابدأ اليوميات'),
          ),
        ],
      ),
    );
  }
}