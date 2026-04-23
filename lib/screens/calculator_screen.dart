import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../widgets/mode_selector.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const ModeSelector(),

            const Expanded(
              flex: 2,
              child: DisplayArea(),
            ),

            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF17181A) : const Color(0xFFF7F8FB),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
                ),

                // HIỆU ỨNG CHUYỂN ĐỔI CHẾ ĐỘ BÀN PHÍM
                child: Selector<CalculatorProvider, CalculatorMode>(
                  selector: (context, provider) => provider.mode,
                  builder: (context, mode, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: ButtonGrid(key: ValueKey(mode)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}