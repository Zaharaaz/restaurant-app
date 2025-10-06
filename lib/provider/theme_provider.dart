import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _keyTheme = "isDarkTheme";
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_keyTheme) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkTheme = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, value);
  }

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
}
