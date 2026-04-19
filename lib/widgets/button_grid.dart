import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);

    final List<String> basicButtons = [
      'C', 'CE', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '±', '0', '.', '='
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
      ),
      itemCount: basicButtons.length,
      itemBuilder: (context, index) {
        String btnText = basicButtons[index];
        return _buildButton(btnText, provider, context);
      },
    );
  }


  Widget _buildButton(String text, CalculatorProvider provider, BuildContext context) {
    Color bgColor = Theme.of(context).cardColor;
    Color textColor = Colors.white;

    if (['÷', '×', '-', '+', '='].contains(text)) {
      bgColor = const Color(0xFF4ECDC4);
      textColor = Colors.black;
    } else if (['C', 'CE', '%', '±'].contains(text)) {
      bgColor = const Color(0xFF3A3A3A);
    }

    return CalculatorButton(
      text: text,
      bgColor: bgColor,
      textColor: textColor,
      isIcon: text == 'CE',
      icon: text == 'CE' ? CupertinoIcons.delete_left : null,
      onTap: () {
        if (text == 'C') {
          provider.clear();
        } else if (text == 'CE') {
          provider.clearEntry();
        } else if (text == '=') {
          provider.calculate();
        } else if (text == '×' || text == '÷' || text == '-' || text == '+') {
          provider.addExpression(text);
        } else if (text == '±') {
          // Sẽ thêm hàm toggleSign vào provider sau
        } else if (text == '%') {
          // Sẽ thêm hàm addPercentage vào provider sau
        } else {
          provider.addExpression(text);
        }
      },
    );
  }
}