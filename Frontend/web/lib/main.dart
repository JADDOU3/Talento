import 'package:flutter/material.dart';
import 'util/theme/app_colors.dart';
import 'features/home/pages/home_page.dart';
import 'features/catalog/pages/catalog_page.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/catalog': (context) => const CatalogPage(),
      },
    );
  }
}