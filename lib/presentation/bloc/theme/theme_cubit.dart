import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/settings_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsService _settingsService;

  ThemeCubit(this._settingsService) : super(_settingsService.getThemeMode());

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _settingsService.setThemeMode(newMode);
    emit(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    _settingsService.setThemeMode(mode);
    emit(mode);
  }
}
