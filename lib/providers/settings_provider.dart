import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTextSize {
  small('Small', 0.9),
  standard('Default', 1.0),
  large('Large', 1.15);

  const AppTextSize(this.label, this.scale);
  final String label;
  final double scale;
}

/// App preferences (appearance and text size), remembered on the device.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    ThemeMode initialThemeMode = ThemeMode.light,
    AppTextSize initialTextSize = AppTextSize.standard,
  })  : _themeMode = initialThemeMode,
        _textSize = initialTextSize;

  static const _themeKey = 'settings.themeMode';
  static const _textSizeKey = 'settings.textSize';

  ThemeMode _themeMode;
  AppTextSize _textSize;

  ThemeMode get themeMode => _themeMode;
  AppTextSize get textSize => _textSize;

  /// Reads saved preferences; falls back to defaults if storage is unavailable.
  static Future<SettingsProvider> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return SettingsProvider(
        initialThemeMode: ThemeMode.values.firstWhere(
            (m) => m.name == prefs.getString(_themeKey),
            orElse: () => ThemeMode.light),
        initialTextSize: AppTextSize.values.firstWhere(
            (s) => s.name == prefs.getString(_textSizeKey),
            orElse: () => AppTextSize.standard),
      );
    } catch (_) {
      return SettingsProvider();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    _save(_themeKey, mode.name);
  }

  void setTextSize(AppTextSize size) {
    if (size == _textSize) return;
    _textSize = size;
    notifyListeners();
    _save(_textSizeKey, size.name);
  }

  Future<void> _save(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      // The setting still applies for this session.
    }
  }
}
