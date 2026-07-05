// lib/features/blog/models/blog_post.dart

import 'package:flutter/material.dart';

class BlogPost {
  final String id;
  final String titleEn;
  final String titleAr;
  final String excerptEn;
  final String excerptAr;
  final List<String> bodyEn;
  final List<String> bodyAr;
  final IconData icon;

  const BlogPost({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.excerptEn,
    required this.excerptAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.icon,
  });

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String excerpt(bool isArabic) => isArabic ? excerptAr : excerptEn;
  List<String> body(bool isArabic) => isArabic ? bodyAr : bodyEn;
}