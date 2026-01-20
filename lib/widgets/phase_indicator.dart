import 'package:flutter/material.dart';

class PhaseIndicator extends StatelessWidget {
  final bool isRunning;
  final bool isFocus;

  const PhaseIndicator({
    super.key,
    required this.isRunning,
    required this.isFocus,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFocus 
        ? const Color(0xFFFF6B6B) 
        : const Color(0xFF4ECDC4);
    
    final opacity = isRunning ? 1.0 : 0.6;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Text(
        isFocus ? 'ODAK ZAMANI' : 'MOLA ZAMANI',
        style: TextStyle(
          fontSize: 14,
          color: color.withOpacity(opacity),
          fontWeight: FontWeight.w300,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}