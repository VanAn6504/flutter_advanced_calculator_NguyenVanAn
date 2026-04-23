import 'package:flutter/material.dart';
import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<CalculationHistory> _history = [];

  List<CalculationHistory> get history => _history;

  HistoryProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _history = await StorageService.loadHistory();
    notifyListeners();
  }

  void addRecord(String expression, String result, int limit) {
    if (expression.isEmpty || result == '0' || result == 'Error') return;

    final newRecord = CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    );

    _history.insert(0, newRecord);

    if (_history.length > limit) {
      _history = _history.sublist(0, limit);
    }

    StorageService.saveHistory(_history);
    notifyListeners();
  }

  void clearAll() {
    _history.clear();
    StorageService.saveHistory(_history);
    notifyListeners();
  }
}