import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's current language and persists the choice across restarts.
/// Switching to Arabic also flips the app to RTL automatically (handled by
/// MaterialApp via the `locale`/`supportedLocales` config in main.dart).
class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_language';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// Loads the previously saved language (if any). Call once at app startup.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'ar' && _locale.languageCode != 'ar') {
        _locale = const Locale('ar');
        notifyListeners();
      }
    } catch (_) {
      // Ignore — default to English if prefs aren't available.
    }
  }

  /// Switches the app language ('en' or 'ar') and saves the choice.
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}
  }
}
