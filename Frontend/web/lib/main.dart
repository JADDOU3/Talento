import 'package:flutter/material.dart';
import 'util/theme/app_colors.dart';
import 'util/theme/app_text_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talento',

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
      ),

      home: Scaffold(
        body: Center(
          child: Text(
            'Setup Ready',
            style: AppTextStyles.heading,
          ),
        ),
      ),
    );
  }
}