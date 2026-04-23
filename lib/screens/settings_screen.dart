import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../models/calculator_mode.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final calcProvider = context.watch<CalculatorProvider>();
    final historyProvider = context.read<HistoryProvider>();
    final settings = calcProvider.settings;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Cài đặt', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          // MỞ MÀN HÌNH LỊCH SỬ
          ListTile(
            leading: Icon(Icons.history, color: textColor?.withOpacity(0.7)),
            title: Text('Xem lịch sử tính toán', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor?.withOpacity(0.5)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          const Divider(color: Colors.grey),

          // THEME
          ListTile(
            leading: Icon(Icons.brightness_6, color: textColor?.withOpacity(0.7)),
            title: Text('Giao diện (Theme)', style: TextStyle(color: textColor)),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              dropdownColor: Theme.of(context).cardColor,
              style: const TextStyle(color: Colors.cyan, fontSize: 16),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Hệ thống', style: TextStyle(color: textColor))),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Sáng', style: TextStyle(color: textColor))),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối', style: TextStyle(color: textColor))),
              ],
              onChanged: (mode) {
                if (mode != null) themeProvider.setTheme(mode);
              },
            ),
          ),

          // ANGLE MODE (Chỉ hiện khi ở Scientific)
          if (calcProvider.mode == CalculatorMode.scientific)
            ListTile(
              leading: Icon(Icons.square_foot, color: textColor?.withOpacity(0.7)),
              title: Text('Đơn vị góc (Angle Mode)', style: TextStyle(color: textColor)),
              trailing: DropdownButton<AngleMode>(
                value: calcProvider.angleMode,
                dropdownColor: Theme.of(context).cardColor,
                style: const TextStyle(color: Colors.cyan, fontSize: 16),
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: AngleMode.degrees, child: Text('Degrees (Độ)', style: TextStyle(color: textColor))),
                  DropdownMenuItem(value: AngleMode.radians, child: Text('Radians', style: TextStyle(color: textColor))),
                ],
                onChanged: (mode) {
                  if (mode != null) calcProvider.setAngleMode(mode);
                },
              ),
            ),

          // PRECISION
          ListTile(
            leading: Icon(Icons.calculate, color: textColor?.withOpacity(0.7)),
            title: Text('Số chữ số thập phân', style: TextStyle(color: textColor)),
            trailing: DropdownButton<int>(
              value: settings.decimalPrecision,
              dropdownColor: Theme.of(context).cardColor,
              style: const TextStyle(color: Colors.cyan, fontSize: 16),
              underline: const SizedBox(),
              items: List.generate(9, (index) {
                int val = index + 2;
                return DropdownMenuItem(value: val, child: Text('$val', style: TextStyle(color: textColor)));
              }),
              onChanged: (val) {
                if (val != null) calcProvider.updatePrecision(val);
              },
            ),
          ),

          // LƯU TRỮ LỊCH SỬ
          ListTile(
            leading: Icon(Icons.data_usage, color: textColor?.withOpacity(0.7)),
            title: Text('Giới hạn lưu lịch sử', style: TextStyle(color: textColor)),
            trailing: DropdownButton<int>(
              value: settings.historySize,
              dropdownColor: Theme.of(context).cardColor,
              style: const TextStyle(color: Colors.cyan, fontSize: 16),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 25, child: Text('25 phép tính', style: TextStyle(color: textColor))),
                DropdownMenuItem(value: 50, child: Text('50 phép tính', style: TextStyle(color: textColor))),
                DropdownMenuItem(value: 100, child: Text('100 phép tính', style: TextStyle(color: textColor))),
              ],
              onChanged: (val) {
                if (val != null) calcProvider.setHistorySize(val);
              },
            ),
          ),
          const Divider(color: Colors.grey),

          // RUNG & ÂM THANH
          SwitchListTile(
            secondary: Icon(Icons.vibration, color: textColor?.withOpacity(0.7)),
            title: Text('Rung khi chạm phím', style: TextStyle(color: textColor)),
            activeColor: Colors.cyan,
            value: settings.hapticFeedback,
            onChanged: (val) => calcProvider.toggleHaptic(val),
          ),
          SwitchListTile(
            secondary: Icon(Icons.volume_up, color: textColor?.withOpacity(0.7)),
            title: Text('Âm thanh bàn phím', style: TextStyle(color: textColor)),
            activeColor: Colors.cyan,
            value: settings.soundEffects,
            onChanged: (val) => calcProvider.toggleSound(val),
          ),
          const Divider(color: Colors.grey),

          // XÓA TOÀN BỘ LỊCH SỬ
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Xóa toàn bộ lịch sử', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  title: Text('Xác nhận xóa', style: TextStyle(color: textColor)),
                  content: Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử tính toán không?', style: TextStyle(color: textColor?.withOpacity(0.8))),
                  actions: [
                    TextButton(
                      child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                      onPressed: () {
                        historyProvider.clearAll();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa lịch sử!'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}