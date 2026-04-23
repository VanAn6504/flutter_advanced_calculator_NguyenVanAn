import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';
import '../screens/history_screen.dart';

class DisplayArea extends StatefulWidget {
  const DisplayArea({super.key});

  @override
  State<DisplayArea> createState() => _DisplayAreaState();
}

class _DisplayAreaState extends State<DisplayArea> {
  double _baseFontSize = 48.0;
  double _currentFontSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final isError = provider.result == 'Error';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) => _baseFontSize = _currentFontSize,
      onScaleUpdate: (details) {
        if (details.pointerCount >= 2 || details.scale != 1.0) {
          setState(() {
            _currentFontSize = (_baseFontSize * details.scale).clamp(24.0, 80.0);
          });
        }
      },
      onScaleEnd: (details) {
        final dx = details.velocity.pixelsPerSecond.dx;
        final dy = details.velocity.pixelsPerSecond.dy;
        if (dx > 500 && dx.abs() > dy.abs()) provider.clearEntry();
        else if (dy < -500 && dy.abs() > dx.abs()) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        alignment: Alignment.bottomRight,

        // HIỆU ỨNG RUNG LẮC (SHAKE ANIMATION) KHI CÓ LỖI
        child: ShakeWidget(
          shouldShake: isError,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (provider.mode == CalculatorMode.programmer)
                _buildProgrammerBases(provider, context),

              if (provider.mode != CalculatorMode.programmer)
              // HIỆU ỨNG FADE-IN KẾT QUẢ (ANIMATED SWITCHER)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Text(
                    provider.result,
                    key: ValueKey<String>(provider.result),
                    style: AppTextStyles.historyText.copyWith(
                      color: isError ? Colors.redAccent : Colors.grey,
                      fontWeight: isError ? FontWeight.bold : FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  provider.expression.isEmpty ? '0' : provider.expression,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: _currentFontSize,
                    fontWeight: FontWeight.w500,
                    color: isError ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgrammerBases(CalculatorProvider provider, BuildContext context) {

    final theme = Theme.of(context);
    return Column(
      children: [
        _buildBaseRow("HEX", provider.hexValue, provider.currentBase == Base.hex, () => provider.setBase(Base.hex), theme),
        _buildBaseRow("DEC", provider.decValue, provider.currentBase == Base.dec, () => provider.setBase(Base.dec), theme),
        _buildBaseRow("OCT", provider.octValue, provider.currentBase == Base.oct, () => provider.setBase(Base.oct), theme),
        _buildBaseRow("BIN", provider.binValue, provider.currentBase == Base.bin, () => provider.setBase(Base.bin), theme),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBaseRow(String label, String value, bool isActive, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isActive ? theme.colorScheme.secondary : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 20),
            Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: isActive ? theme.textTheme.bodyLarge?.color : Colors.grey, fontSize: 16, fontFamily: 'monospace'))),
          ],
        ),
      ),
    );
  }
}

// WIDGET TẠO HIỆU ỨNG RUNG LẮC
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shouldShake;

  const ShakeWidget({super.key, required this.child, required this.shouldShake});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue = math.sin(_controller.value * 3 * math.pi);
        return Transform.translate(
          offset: Offset(sineValue * 12, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}