import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFCFD),
              Color(0xFFFFF1F4),
              Color(0xFFFFFAF1),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFEC6886).withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC6886).withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC6886).withOpacity(0.11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFFEC6886),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'افهم رحلة طفلك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF086D66),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 44,
                  height: 44,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'اطّلع على تحليل الأداء، ونمط التفكير الأقرب لطفلك، ونقاط القوة وفرص التطوّر.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.4,
                color: Color(0xFF4F5870),
                height: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEF7893),
                      Color(0xFFEC6886),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC6886).withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'عرض اليوميات والتحليل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}