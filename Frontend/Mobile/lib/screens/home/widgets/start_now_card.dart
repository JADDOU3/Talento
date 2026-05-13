import 'package:flutter/material.dart';

class StartNowCard extends StatelessWidget {
  final VoidCallback? onTap;

  const StartNowCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ابدأ الآن',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1F24),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'أضف بيانات طفلك الصغير',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B728F)),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E8EE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10A896).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Color(0xFF10A896),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أضف بيانات الطفل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1F24),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'ستقوم بتخصيص تجربته بناءً على اهتماماته',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B728F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10A896),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('ابدأ الآن'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}