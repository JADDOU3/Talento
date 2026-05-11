// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared/providers/language_provider.dart';
import 'shared/i18n/app_localizations.dart';
import 'features/home/pages/home_page.dart';
import 'features/catalog/pages/catalog_page.dart';
import 'features/cart/pages/cart_page.dart';
import 'features/catalog/pages/kit_details_page.dart';
import 'features/catalog/cubits/kit/kit_cubit.dart';
import 'util/theme/app_colors.dart';

void main() {
  runApp(
    // LanguageProvider يغلف الكل عشان اللغة تشتغل في كل مكان
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const TalentoApp(),
    ),
  );
}

class TalentoApp extends StatelessWidget {
  const TalentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.locale.languageCode == 'ar';

    return BlocProvider(
      // KitCubit على مستوى الـ app عشان يبقى موجود بين الصفحات
      create: (_) => KitCubit(),
      child: MaterialApp(
        title: 'Talento',
        debugShowCheckedModeBanner: false,
        locale: languageProvider.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          textTheme: isArabic
              ? GoogleFonts.cairoTextTheme()
              : GoogleFonts.nunitoTextTheme(),
          fontFamily: isArabic
              ? GoogleFonts.cairo().fontFamily
              : GoogleFonts.nunito().fontFamily,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/home': (context) => const HomePage(),
          '/catalog': (context) => const CatalogPage(),
          '/kit-details': (context) => const KitDetailsPage(),
        },
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CartPage(),
        '/home': (context) => const HomePage(),
        '/catalog': (context) => const CatalogPage(),
       // '/cart': (context) => const CartPage(),
      },

    );
  }
}