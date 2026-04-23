import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    String? savedTheme = await StorageService.loadTheme();
    if (savedTheme == 'light') _themeMode = ThemeMode.light;
    else if (savedTheme == 'dark') _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: AppColors.lightSecondary,
    colorScheme: const ColorScheme.light(primary: AppColors.lightPrimary, secondary: AppColors.lightAccent),
    fontFamily: 'Roboto',
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: AppColors.darkSecondary,
    colorScheme: const ColorScheme.dark(primary: AppColors.darkPrimary, secondary: AppColors.darkAccent),
    fontFamily: 'Roboto',
  );

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    StorageService.saveTheme(mode.toString().split('.').last);
    notifyListeners();
  }
}