import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'language_code';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  ThemeMode getThemeMode() {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex == null) return ThemeMode.system;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeKey, mode.index);
  }

  Locale? getLocale() {
    final languageCode = _prefs.getString(_localeKey);
    if (languageCode == null) return null;
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}
