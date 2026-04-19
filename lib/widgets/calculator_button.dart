import 'package:flutter/material.dart';

class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final bool isIcon;
  final IconData? icon;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onTap,
    this.bgColor = const Color(0xFF2C2C2C),
    this.textColor = Colors.white,
    this.isIcon = false,
    this.icon,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          alignment: Alignment.center,
          child: widget.isIcon
              ? Icon(widget.icon, color: widget.textColor, size: 24)
              : Text(
            widget.text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}