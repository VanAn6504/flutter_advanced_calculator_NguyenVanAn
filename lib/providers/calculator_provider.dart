import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../models/calculator_mode.dart';

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  CaculatorMode _mode = CaculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  double _memory = 0;
  bool _hasMemory = false;

  String get expression => _expression;

  String get result => _result;

  CaculatorMode get mode => _mode;

  bool get hasMemory => _hasMemory;

  void addExpression(String value) {
    _expression += value;
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '0';
    notifyListeners();
  }

  void clearEntry() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      notifyListeners();
    }
  }

  void calculate() {
    try {
      String finalExpression = _expression.replaceAll('x', '*').replaceAll(
          '÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);
      _result = evalResult.toString();

      if (_result.endsWith('.0')) {
        _result = _result.substring(0, _result.length - 2);
      }
    } catch (e) {
      _result = 'Error';
    }
    notifyListeners();
  }

  void memoryAdd() {
    _memory += double.tryParse(_result) ?? 0;
    _hasMemory = true;
    notifyListeners();
  }

  void memoryClear() {
    _memory = 0;
    _hasMemory = false;
    notifyListeners();
  }
}