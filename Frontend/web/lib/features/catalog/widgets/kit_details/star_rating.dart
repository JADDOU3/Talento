import 'package:flutter/material.dart';

/// Displays a row of stars for a fractional rating (e.g. 4.5).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 18,
    this.spacing = 2,
    this.filledColor = const Color(0xFFD64562),
    this.emptyColor = const Color(0x33D64562),
  });

  final double rating;
  final int maxStars;
  final double size;
  final double spacing;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: List.generate(maxStars, (i) {
        final starValue = (rating - i).clamp(0.0, 1.0);
        IconData icon;
        if (starValue >= 1) {
          icon = Icons.star_rounded;
        } else if (starValue > 0) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Padding(
          padding: EdgeInsetsDirectional.only(end: i == maxStars - 1 ? 0 : spacing),
          child: Icon(
            icon,
            size: size,
            color: starValue > 0 ? filledColor : emptyColor,
          ),
        );
      }),
    );
  }
}
