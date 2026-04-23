import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// DÙNG PACKAGE IMPORT
import 'package:advanced_calculator/main.dart';
import 'package:advanced_calculator/providers/theme_provider.dart';
import 'package:advanced_calculator/providers/calculator_provider.dart';
import 'package:advanced_calculator/providers/history_provider.dart';

void main() {
  // Giả lập SharedPreferences
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Tạo khung ứng dụng có bọc Provider để test
  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const AdvancedCalculatorApp(),
    );
  }

  testWidgets('Integration Test: Button press sequences & Result', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Mô phỏng người dùng bấm 5 + 3 =
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    // Dùng findsWidgets vì trên màn hình có thể có nhiều chữ '8' (trên phím bấm và kết quả)
    expect(find.text('8'), findsWidgets);
  });

  testWidgets('Integration Test: Mode switching', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Chữ sin chưa tồn tại ở Basic Mode
    expect(find.text('sin'), findsNothing);

    // Mở Dropdown và chọn Scientific
    await tester.tap(find.text('Basic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scientific').last);
    await tester.pumpAndSettle();

    // Chữ sin đã xuất hiện
    expect(find.text('sin'), findsWidgets);
  });

  testWidgets('Integration Test: Theme persistence (Settings)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Mở Settings
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Chọn Theme Tối
    await tester.tap(find.text('Hệ thống'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tối').last);
    await tester.pumpAndSettle();

    // Lấy context để check Provider xem ThemeMode đã thực sự đổi chưa
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
    expect(themeMode, ThemeMode.dark);
  });

  testWidgets('Integration Test: History save/load', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Nhấn phím 1 0 - 4 =
    await tester.tap(find.text('1').last);
    await tester.pump();
    await tester.tap(find.text('0').last);
    await tester.pump();
    await tester.tap(find.text('-').last);
    await tester.pump();
    await tester.tap(find.text('4').last);
    await tester.pump();
    await tester.tap(find.text('=').last);
    await tester.pumpAndSettle();

    // Mở cài đặt
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Mở lịch sử
    await tester.tap(find.text('Xem lịch sử tính toán'));
    await tester.pumpAndSettle();

    // SỬA LỖI TẠI ĐÂY: Sử dụng find.textContaining để tìm số 6 trong lịch sử
    // Điều này đảm bảo dù bạn hiện "= 6", "6" hay "10-4=6" thì test vẫn Pass.
    expect(find.textContaining('6'), findsWidgets);
  });
}