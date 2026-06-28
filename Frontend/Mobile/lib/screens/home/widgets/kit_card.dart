import 'package:flutter/material.dart';

class KitCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final VoidCallback? onTap;

  const KitCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isEmpty ? description.trim() : title.trim();
    final displayDescription = description.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 166,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE1F2F0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10A896).withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: SizedBox(
                      height: 112,
                      width: double.infinity,
                      child: _buildImage(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF44D1D8),
                            Color(0xFF10A896),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10A896).withOpacity(0.20),
                            blurRadius: 9,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1F24),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (displayDescription.isNotEmpty)
                        Text(
                          displayDescription,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11.3,
                            color: Color(0xFF6B728F),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }

    if (image.isNotEmpty) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }

    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      height: 112,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF44D1D8),
            Color(0xFF10A896),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }
}