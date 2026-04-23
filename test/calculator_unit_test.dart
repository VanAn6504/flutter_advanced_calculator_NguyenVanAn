import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DÙNG PACKAGE IMPORT ĐỂ TRÁNH LỖI CONFLICT TYPE
import 'package:advanced_calculator/providers/calculator_provider.dart';
import 'package:advanced_calculator/models/calculator_mode.dart';

void main() {
  // Giả lập bộ nhớ thiết bị trước khi test
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Calculator Logic Tests', () {
    late CalculatorProvider calculator;

    setUp(() async {
      calculator = CalculatorProvider();
      await Future.delayed(Duration.zero); // Chờ khởi tạo provider
    });

    // Hàm hỗ trợ nhập và tính toán nhanh
    void calculateExpr(String expr) {
      calculator.clear();
      calculator.addToExpression(expr);
      calculator.calculate();
    }

    test('Basic arithmetic operations', () {
      calculateExpr('5+3');
      expect(calculator.result, '8');

      calculateExpr('10-4');
      expect(calculator.result, '6');

      calculateExpr('6×7');
      expect(calculator.result, '42');

      calculateExpr('15÷3');
      expect(calculator.result, '5');
    });

    test('Order of operations', () {
      calculateExpr('2+3×4');
      expect(calculator.result, '14');

      calculateExpr('(2+3)×4');
      expect(calculator.result, '20');
    });

    test('Scientific functions', () {
      calculator.setAngleMode(AngleMode.degrees);

      calculateExpr('sin(30)');
      expect(calculator.result, '0.5');

      // Trên UI người dùng bấm √ rồi bấm 16 rồi bấm )
      calculateExpr('√(16)');
      expect(calculator.result, '4');
    });

    test('Edge cases', () {
      calculateExpr('5÷0');
      expect(calculator.result, 'Error'); // Xử lý báo lỗi chia cho 0

      calculateExpr('√(-4)');
      expect(calculator.result, 'Error'); // Căn bậc 2 số âm báo lỗi
    });
  });
}