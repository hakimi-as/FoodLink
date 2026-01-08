import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default to light mode (false)
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Returns the correct mode for MaterialApp to use
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Function to toggle the theme (accepts the boolean from the Switch)
  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    notifyListeners(); // This tells the app to rebuild with the new theme
  }
}