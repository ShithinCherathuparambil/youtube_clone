import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/settings_service.dart';

@injectable
class LanguageCubit extends Cubit<Locale?> {
  final SettingsService _settingsService;

  LanguageCubit(this._settingsService) : super(null) {
    _loadLocale();
  }

  void _loadLocale() {
    final locale = _settingsService.getLocale();
    emit(locale);
  }

  Future<void> setLocale(Locale locale) async {
    await _settingsService.setLocale(locale);
    emit(locale);
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta'),
    Locale('ur'),
    Locale('ar'),
    Locale('kn'),
  ];

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'ml':
        return 'മലയാളം';
      case 'ta':
        return 'தமிழ்';
      case 'ur':
        return 'اردو';
      case 'ar':
        return 'العربية';
      case 'kn':
        return 'ಕನ್ನಡ';
      default:
        return 'English';
    }
  }
}
