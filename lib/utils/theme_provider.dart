import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final theme = await PreferencesService.getThemeMode();
    _isDarkMode = theme == 'dark';
    notifyListeners();
  }
  
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesService.setThemeMode(_isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}