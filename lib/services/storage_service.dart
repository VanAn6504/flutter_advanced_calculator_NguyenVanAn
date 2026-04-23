import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';

class StorageService {
  static const String _historyKey = 'calculation_history';
  static const String _settingsKey = 'calculator_settings';
  static const String _themeKey = 'calculator_theme';

  // --- LỊCH SỬ ---
  static Future<void> saveHistory(List<CalculationHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encodedData);
  }

  static Future<List<CalculationHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);
    if (historyString == null) return [];
    final List<dynamic> decodedData = jsonDecode(historyString);
    return decodedData.map((item) => CalculationHistory.fromJson(item)).toList();
  }

  // --- CÀI ĐẶT ---
  static Future<void> saveSettings(CalculatorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  static Future<CalculatorSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsString = prefs.getString(_settingsKey);
    if (settingsString == null) return CalculatorSettings();
    return CalculatorSettings.fromJson(jsonDecode(settingsString));
  }

  // --- THEME ---
  static Future<void> saveTheme(String themeValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeValue);
  }

  static Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  // --- TRẠNG THÁI MÁY TÍNH (MODE & MEMORY) ---
  static Future<void> saveAppState(String mode, double memory, bool hasMemory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calc_mode', mode);
    await prefs.setDouble('calc_memory', memory);
    await prefs.setBool('calc_has_memory', hasMemory);
  }

  static Future<Map<String, dynamic>> loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mode': prefs.getString('calc_mode') ?? 'CalculatorMode.basic',
      'memory': prefs.getDouble('calc_memory') ?? 0.0,
      'hasMemory': prefs.getBool('calc_has_memory') ?? false,
    };
  }
}