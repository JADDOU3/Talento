import 'package:flutter/material.dart';

class KitCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String age;
  final String image;

  const KitCard({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.age,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image(
                image: AssetImage(image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10A896), Color(0xFF48C5DC)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 36),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1F24),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF6B728F)),
                    const SizedBox(width: 3),
                    Text(duration, style: const TextStyle(fontSize: 11, color: Color(0xFF6B728F))),
                    const SizedBox(width: 8),
                    const Icon(Icons.child_care_rounded, size: 12, color: Color(0xFF6B728F)),
                    const SizedBox(width: 3),
                    Text(age, style: const TextStyle(fontSize: 11, color: Color(0xFF6B728F))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}