<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Talento Ready'),
        ),
      ),
    );
  }
=======
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/owned_kit/owned_kit_screen.dart';
import 'screens/community/community_screen.dart';

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
      theme: AppTheme.lightTheme,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const  ProfileScreen(),

    );
  }
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e
}