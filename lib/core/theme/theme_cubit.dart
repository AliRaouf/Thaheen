import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/settings_store.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._settings) : super(_settings.themeMode);

  final SettingsStore _settings;

  void toggleTheme(Brightness shownTheme) {
    final theme = shownTheme == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _settings.setThemeMode(theme);
    emit(theme);
  }
}
