import 'package:flutter/material.dart';

class LevelIndicator extends StatelessWidget {
  final String level;
  final int dailyMinutes;
  final int completedPomodoros;

  const LevelIndicator({
    super.key,
    required this.level,
    required this.dailyMinutes,
    required this.completedPomodoros,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = _getLevelEmoji(level);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: Text(
        '$emoji $level • ${dailyMinutes}dk • $completedPomodoros pomodoro',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withOpacity(0.4),
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  String _getLevelEmoji(String level) {
    switch (level) {
      case 'Başlangıç':
        return '🌱';
      case 'Orta':
        return '🌿';
      case 'Disiplinli':
        return '🌳';
      default:
        return '🌱';
    }
  }
}