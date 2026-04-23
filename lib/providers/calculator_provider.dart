import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';

enum Base { hex, dec, oct, bin }

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  bool _is2ndMode = false;
  double _memory = 0;
  bool _hasMemory = false;
  Base _currentBase = Base.dec;
  int _programmerValue = 0;
  CalculatorSettings _settings = CalculatorSettings();

  CalculatorProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    _settings = await StorageService.loadSettings();
    _angleMode = _settings.angleMode == 'radians' ? AngleMode.radians : AngleMode.degrees;
    final state = await StorageService.loadAppState();
    String savedMode = state['mode'];
    _mode = CalculatorMode.values.firstWhere((e) => e.toString() == savedMode, orElse: () => CalculatorMode.basic);
    _memory = state['memory'];
    _hasMemory = state['hasMemory'];
    notifyListeners();
  }

  String get expression => _expression;
  String get result => _result;
  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  bool get hasMemory => _hasMemory;
  Base get currentBase => _currentBase;
  CalculatorSettings get settings => _settings;
  bool get is2ndMode => _is2ndMode;

  int get _radix {
    if (_currentBase == Base.hex) return 16;
    if (_currentBase == Base.oct) return 8;
    if (_currentBase == Base.bin) return 2;
    return 10;
  }

  String get hexValue => _programmerValue.toRadixString(16).toUpperCase();
  String get decValue => _programmerValue.toString();
  String get octValue => _programmerValue.toRadixString(8);
  String get binValue => _programmerValue.toRadixString(2).padLeft(8, '0');

  void _saveAppState() {
    StorageService.saveAppState(_mode.toString(), _memory, _hasMemory);
  }

  void updatePrecision(int precision) {
    _settings.decimalPrecision = precision;
    StorageService.saveSettings(_settings);
    if (_result != '0' && _result != 'Error') calculate();
    notifyListeners();
  }

  void toggleHaptic(bool value) {
    _settings.hapticFeedback = value;
    StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void toggleSound(bool value) {
    _settings.soundEffects = value;
    StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void setHistorySize(int size) {
    _settings.historySize = size;
    StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    _angleMode = mode;
    _settings.angleMode = mode == AngleMode.degrees ? 'degrees' : 'radians';
    StorageService.saveSettings(_settings);
    if (_result != '0' && _result != 'Error') calculate();
    notifyListeners();
  }

  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    _is2ndMode = false;
    _saveAppState();
    clear();
  }

  void toggle2ndMode() {
    _is2ndMode = !_is2ndMode;
    notifyListeners();
  }

  void setBase(Base newBase) {
    _currentBase = newBase;
    _updateProgrammerValue();
    notifyListeners();
  }

  void addToExpression(String value) {
    _expression += value;
    if (_mode == CalculatorMode.programmer) _updateProgrammerValue();
    notifyListeners();
  }

  void addProgrammerOperator(String op) {
    if (_expression.isNotEmpty && !_expression.endsWith(' ')) {
      _expression += ' $op ';
      notifyListeners();
    }
  }

  void clear() {
    _expression = '';
    _result = '0';
    _programmerValue = 0;
    notifyListeners();
  }

  void clearEntry() {
    if (_expression.isNotEmpty) {
      if (_expression.endsWith(' ')) {
        _expression = _expression.substring(0, _expression.length - 3);
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      if (_mode == CalculatorMode.programmer) _updateProgrammerValue();
      notifyListeners();
    }
  }

  String _preProcessExpression(String expr) {
    String finalExpr = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('π', math.pi.toString()).replaceAll('e', math.e.toString()).replaceAll('x²', '^2').replaceAll('x³', '^3').replaceAll('√', 'sqrt');
    finalExpr = finalExpr.replaceAllMapped(RegExp(r'(\d+|\)|π|e)(?=\(|sin|cos|tan|asin|acos|atan|ln|log|π|e)'), (Match m) => '${m.group(1)}*');
    finalExpr = finalExpr.replaceAllMapped(RegExp(r'∛\((.*?)\)'), (m) => '(${m.group(1)})^(1/3)');
    finalExpr = finalExpr.replaceAllMapped(RegExp(r'log₂\((.*?)\)'), (m) => '(ln(${m.group(1)})/ln(2))');
    finalExpr = finalExpr.replaceAllMapped(RegExp(r'(\d+)!'), (Match m) {
      int n = int.parse(m.group(1)!);
      return _calculateFactorial(n).toString();
    });

    if (_angleMode == AngleMode.degrees) {
      finalExpr = finalExpr.replaceAllMapped(RegExp(r'sin\((.*?)\)'), (m) => 'sin((${m.group(1)})*(${math.pi}/180))')
          .replaceAllMapped(RegExp(r'cos\((.*?)\)'), (m) => 'cos((${m.group(1)})*(${math.pi}/180))')
          .replaceAllMapped(RegExp(r'tan\((.*?)\)'), (m) => 'tan((${m.group(1)})*(${math.pi}/180))');
      finalExpr = finalExpr.replaceAllMapped(RegExp(r'asin\((.*?)\)'), (m) => '(arcsin(${m.group(1)})*(180/${math.pi}))')
          .replaceAllMapped(RegExp(r'acos\((.*?)\)'), (m) => '(arccos(${m.group(1)})*(180/${math.pi}))')
          .replaceAllMapped(RegExp(r'atan\((.*?)\)'), (m) => '(arctan(${m.group(1)})*(180/${math.pi}))');
    } else {
      finalExpr = finalExpr.replaceAll('asin', 'arcsin').replaceAll('acos', 'arccos').replaceAll('atan', 'arctan');
    }
    return finalExpr;
  }

  double _calculateFactorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  int _evaluateProgrammer(String expr) {
    if (expr.trim().isEmpty) return 0;
    List<String> tokens = expr.trim().split(RegExp(r'\s+'));

    try {
      int result = int.parse(tokens[0], radix: _radix);
      for (int i = 1; i < tokens.length - 1; i += 2) {
        String op = tokens[i];
        int nextVal = int.parse(tokens[i+1], radix: _radix);
        switch (op) {
          case '+': result += nextVal; break;
          case '-': result -= nextVal; break;
          case '×': result *= nextVal; break;
          case '÷': result = nextVal != 0 ? result ~/ nextVal : 0; break;
          case 'AND': result &= nextVal; break;
          case 'OR': result |= nextVal; break;
          case 'XOR': result ^= nextVal; break;
          case '<<': result <<= nextVal; break;
          case '>>': result >>= nextVal; break;
        }
      }
      return result;
    } catch (e) {
      return 0;
    }
  }

  void calculate() {

    if (_expression.isEmpty) return;

    if (_mode == CalculatorMode.programmer) {
      _programmerValue = _evaluateProgrammer(_expression);
      _result = _programmerValue.toRadixString(_radix).toUpperCase();
      notifyListeners();
      return;
    }

    try {
      String processedExpr = _preProcessExpression(_expression);
      Parser p = Parser();
      Expression exp = p.parse(processedExpr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) throw Exception('Math Error');

      _result = eval.toStringAsFixed(_settings.decimalPrecision);
      if (_result.contains('.')) {
        _result = _result.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      _result = 'Error';
    }
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.isNotEmpty) {
      if (_expression.startsWith('-')) _expression = _expression.substring(1);
      else _expression = '-$_expression';
      notifyListeners();
    }
  }

  void addPercentage() {
    if (_expression.isNotEmpty) {
      try {
        double val = double.parse(_expression);
        _expression = (val / 100).toString();
        notifyListeners();
      } catch (e) {}
    }
  }

  void memoryAdd() { calculate(); _memory += double.tryParse(_result) ?? 0; _hasMemory = true; _saveAppState(); notifyListeners(); }
  void memorySubtract() { calculate(); _memory -= double.tryParse(_result) ?? 0; _hasMemory = true; _saveAppState(); notifyListeners(); }
  void memoryRecall() { String memStr = _memory.toString(); if (memStr.endsWith('.0')) memStr = memStr.substring(0, memStr.length - 2); _expression += memStr; notifyListeners(); }
  void memoryClear() { _memory = 0; _hasMemory = false; _saveAppState(); notifyListeners(); }

  void _updateProgrammerValue() {
    _programmerValue = _evaluateProgrammer(_expression);
  }

  void performBitwise(String op) {
    if (_expression.isEmpty) return;
    if (op == 'NOT') {
      int currentVal = _evaluateProgrammer(_expression);
      int newVal = ~currentVal;
      _expression = newVal.toRadixString(_radix).toUpperCase();
      _updateProgrammerValue();
      notifyListeners();
    }
  }

  bool isButtonEnabled(String text) {
    if (_mode != CalculatorMode.programmer) return true;
    if (RegExp(r'^[A-F]$').hasMatch(text)) return _currentBase == Base.hex;
    if (RegExp(r'^[89]$').hasMatch(text)) return _currentBase == Base.dec || _currentBase == Base.hex;
    if (RegExp(r'^[2-7]$').hasMatch(text)) return _currentBase != Base.bin;
    return true;
  }
}