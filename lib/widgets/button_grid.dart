import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../providers/history_provider.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, provider, child) {
        List<String> buttons = _getButtonsForMode(provider.mode);

        int crossAxisCount = 4;
        if (provider.mode == CalculatorMode.scientific) crossAxisCount = 6;
        if (provider.mode == CalculatorMode.programmer) crossAxisCount = 5;

        return LayoutBuilder(
          builder: (context, constraints) {
            const double padding = 24.0;
            const double spacing = 12.0;
            double availableWidth = constraints.maxWidth - (padding * 2);
            double availableHeight = constraints.maxHeight - (padding * 2);
            double itemWidth = (availableWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
            int numRows = (buttons.length / crossAxisCount).ceil();
            double itemHeight = (availableHeight - (numRows - 1) * spacing) / numRows;
            double perfectAspectRatio = itemWidth / itemHeight;

            return GridView.builder(
              padding: const EdgeInsets.all(padding),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: perfectAspectRatio,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                String originalText = buttons[index];

                String displayText = originalText;

                if (originalText == 'CLR') {
                  displayText = 'C';
                }
                // Thay đổi nút khi bấm 2nd ở chế độ scientific
                else if (provider.mode == CalculatorMode.scientific && provider.is2ndMode) {
                  if (originalText == 'sin') displayText = 'asin';
                  else if (originalText == 'cos') displayText = 'acos';
                  else if (originalText == 'tan') displayText = 'atan';
                  else if (originalText == 'log') displayText = 'log₂';
                  else if (originalText == 'x²') displayText = 'x³';
                  else if (originalText == '√') displayText = '∛';
                  else if (originalText == 'ln') displayText = 'n!';
                }

                // Kiểm tra xem phím có được phép bấm không (Dành riêng cho Programmer Mode)
                bool isEnabled = provider.isButtonEnabled(originalText);

                return Opacity(
                  opacity: isEnabled ? 1.0 : 0.3,
                  child: _buildButton(originalText, displayText, provider, context, isEnabled),
                );
              },
            );
          },
        );
      },
    );
  }

  List<String> _getButtonsForMode(CalculatorMode mode) {
    if (mode == CalculatorMode.scientific) {
      return [
        '2nd', 'sin', 'cos', 'tan', 'ln', 'log',
        'x²', '√', '^', '(', ')', '÷',
        'MC', '7', '8', '9', 'CLR', '×',
        'MR', '4', '5', '6', 'CE', '-',
        'M+', '1', '2', '3', '%', '+',
        'M-', '±', '0', '.', 'π', '='
      ];
    } else if (mode == CalculatorMode.programmer) {
      return [
        'A', 'B', 'C', 'D', 'E',
        'F', 'AND', 'OR', 'XOR', 'NOT',
        '<<', '>>', 'CLR', 'CE', '÷',
        '7', '8', '9', '(', '×',
        '4', '5', '6', ')', '-',
        '1', '2', '3', '±', '+',
        '0', '00', '.', '%', '='
      ];
    }
    return [
      'CLR', 'CE', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '±', '0', '.', '='
    ];
  }

  Widget _buildButton(String originalText, String displayText, CalculatorProvider provider, BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;

    if (originalText == '2nd') {
      bgColor = provider.is2ndMode ? theme.colorScheme.secondary : (isDark ? const Color(0xFF1E1F24) : const Color(0xFFE8E9F0));
      textColor = provider.is2ndMode ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87);
    }
    else if (['÷', '×', '-', '+', '='].contains(originalText)) {
      bgColor = theme.colorScheme.secondary;
      textColor = isDark ? Colors.black : Colors.white;
    }
    else if (['CLR', 'CE', '%', '±'].contains(originalText)) {
      bgColor = isDark ? const Color(0xFF4E505F) : const Color(0xFFD2D3DA);
      textColor = isDark ? Colors.white : Colors.black;
    }
    else if (RegExp(r'[A-F]').hasMatch(originalText) || ['AND', 'OR', 'XOR', 'NOT', '<<', '>>', 'sin', 'cos', 'tan', 'ln', 'log', 'x²', '√', '^', '(', ')', 'π', 'MC', 'MR', 'M+', 'M-'].contains(originalText)) {
      bgColor = isDark ? const Color(0xFF1E1F24) : const Color(0xFFE8E9F0);
      textColor = isDark ? Colors.white70 : Colors.black87;
    }
    else {
      bgColor = isDark ? const Color(0xFF2E2F38) : const Color(0xFFFFFFFF);
      textColor = isDark ? Colors.white : Colors.black;
    }

    return CalculatorButton(
      text: displayText,
      bgColor: bgColor,
      textColor: textColor,
      isIcon: originalText == 'CE',
      icon: originalText == 'CE' ? CupertinoIcons.delete_left : null,

      onLongPress: (originalText == 'CLR' && isEnabled) ? () {
        if (provider.settings.hapticFeedback) HapticFeedback.heavyImpact();
        context.read<HistoryProvider>().clearAll();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa toàn bộ lịch sử!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
        );
      } : null,

      onTap: isEnabled ? () {
        if (provider.settings.hapticFeedback) HapticFeedback.lightImpact();
        if (provider.settings.soundEffects) SystemSound.play(SystemSoundType.click);

        if (originalText == 'CLR') provider.clear();
        else if (originalText == 'CE') provider.clearEntry();
        else if (originalText == '=') {
          String currentExpr = provider.expression;
          provider.calculate();
          if (provider.result != 'Error') {
            context.read<HistoryProvider>().addRecord(currentExpr, provider.result, provider.settings.historySize);
          }
        }
        else if (provider.mode == CalculatorMode.programmer && ['+', '-', '×', '÷', 'AND', 'OR', 'XOR', '<<', '>>'].contains(originalText)) {
          provider.addProgrammerOperator(originalText);
        }
        else if (originalText == 'NOT') provider.performBitwise('NOT');
        else if (originalText == '±') provider.toggleSign();
        else if (originalText == '%') provider.addPercentage();
        else if (originalText == '2nd') provider.toggle2ndMode();

        else if (originalText == 'ln' && provider.is2ndMode) provider.addToExpression('!');
        else if (['sin', 'cos', 'tan', 'ln', 'log', '√'].contains(originalText)) {
          provider.addToExpression('$displayText(');
        }

        else if (originalText == 'MC') provider.memoryClear();
        else if (originalText == 'MR') provider.memoryRecall();
        else if (originalText == 'M+') provider.memoryAdd();
        else if (originalText == 'M-') provider.memorySubtract();

        else provider.addToExpression(originalText);
      } : () {},
    );
  }
}