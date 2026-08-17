import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _kThemeMode = 'settings_theme_mode';

  SharedPreferences? _prefs;
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final modeIndex = _prefs?.getInt(_kThemeMode);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      themeMode = ThemeMode.values[modeIndex];
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;
    await _prefs?.setInt(_kThemeMode, mode.index);
    notifyListeners();
  }
}
