import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { classic, monochrome }

class ThemeManager extends ChangeNotifier {
  static final ThemeManager instance = ThemeManager._internal();
  ThemeManager._internal();

  ThemeType _themeType = ThemeType.monochrome;
  ThemeMode _themeMode = ThemeMode.dark;
  SharedPreferences? _prefs;

  ThemeType get themeType => _themeType;
  ThemeMode get themeMode => _themeMode;

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final typeStr = _prefs?.getString('theme_type') ?? 'monochrome';
    _themeType = typeStr == 'classic' ? ThemeType.classic : ThemeType.monochrome;
    
    final modeStr = _prefs?.getString('theme_mode') ?? 'dark';
    if (modeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setThemeType(ThemeType type) async {
    _themeType = type;
    await _prefs?.setString('theme_type', type == ThemeType.monochrome ? 'monochrome' : 'classic');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'dark';
    if (mode == ThemeMode.system) modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    await _prefs?.setString('theme_mode', modeStr);
    notifyListeners();
  }
}
