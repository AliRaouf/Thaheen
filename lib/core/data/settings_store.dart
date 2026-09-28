import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_prefs.getString('theme_mode')] ??
      ThemeMode.system;
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString('theme_mode', mode.name);

  double get playbackSpeed => _prefs.getDouble('playback_speed') ?? 1;
  Future<void> setPlaybackSpeed(double speed) =>
      _prefs.setDouble('playback_speed', speed);
}
