import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../screens/settings_screen.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bên Trái: Dropdown Mode
          DropdownButton<CalculatorMode>(
            value: provider.mode,
            dropdownColor: theme.cardColor,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            onChanged: (CalculatorMode? newValue) {
              if (newValue != null) context.read<CalculatorProvider>().setMode(newValue);
            },
            items: [
              DropdownMenuItem(value: CalculatorMode.basic, child: Text('Basic', style: TextStyle(color: textColor))),
              DropdownMenuItem(value: CalculatorMode.scientific, child: Text('Scientific', style: TextStyle(color: textColor))),
              DropdownMenuItem(value: CalculatorMode.programmer, child: Text('Programmer', style: TextStyle(color: textColor))),
            ],
          ),

          // Bên Phải: Chỉ hiện Memory Icon (nếu có) và Settings Icon
          Row(
            children: [
              if (provider.hasMemory)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Text('M', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: textColor?.withOpacity(0.7), size: 24),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}