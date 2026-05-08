import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
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

    return MaterialApp(
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
        scaffoldBackgroundColor: const Color(0xFFFAF7F4),
        textTheme: isArabic
            ? GoogleFonts.cairoTextTheme()
            : GoogleFonts.nunitoTextTheme(),
        fontFamily: isArabic
            ? GoogleFonts.cairo().fontFamily
            : GoogleFonts.nunito().fontFamily,
      ),
      home: const LoginScreen(),
    );
  }
}