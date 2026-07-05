// lib/features/blog/utils/blog_style.dart

import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';
import '../models/blog_post.dart';

/// Cycles through a small set of brand accent colors so posts read as
/// distinct without needing per-post color data in the model.
const List<Color> blogAccentColors = [
  AppColors.cartTeal,
  Color(0xFFE07A5F), // warm coral, complements the teal/green palette
  AppColors.cartForestGreen,
  Color(0xFFDDA83A), // warm amber, close to AppColors.yellow but higher contrast on white
];

Color blogAccentColorFor(int index) => blogAccentColors[index % blogAccentColors.length];

/// Rough reading time estimate (~200 words/min), shown as "3 min read" /
/// "٣ دقائق قراءة".
int blogReadMinutes(BlogPost post, bool isArabic) {
  final wordCount = post
      .body(isArabic)
      .join(' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;
  return (wordCount / 200).ceil().clamp(1, 99);
}

String blogReadLabel(BlogPost post, bool isArabic) {
  final minutes = blogReadMinutes(post, isArabic);
  return isArabic ? '$minutes دقائق قراءة' : '$minutes min read';
}