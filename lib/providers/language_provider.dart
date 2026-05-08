import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'en';
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
      await prefs.setString('language', 'ar');
    } else {
      _locale = const Locale('en');
      await prefs.setString('language', 'en');
    }
    notifyListeners();
  }
}