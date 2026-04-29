import 'package:flutter/material.dart';
import 'package:mobile/screens/home/old_user_screen.dart';
import 'package:mobile/screens/home/profile_screen.dart';
import 'package:mobile/screens/kit_library/kit_details_screen.dart';
import 'screens/home/new_user.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/kit_library/kit_library_screen.dart';

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
      home: const  SplashScreen(),

    );
  }
}