class PomodoroState {
  final bool isRunning;
  final bool isFocus;
  final int remainingSeconds;
  final int focusDuration;
  final int breakDuration;
  final String userLevel;
  final int dailyFocusMinutes;
  final int completedPomodorosToday;
  final int totalCompletedPomodoros;
  final double focusSuccessRate;

  const PomodoroState({
    required this.isRunning,
    required this.isFocus,
    required this.remainingSeconds,
    required this.focusDuration,
    required this.breakDuration,
    required this.userLevel,
    required this.dailyFocusMinutes,
    required this.completedPomodorosToday,
    required this.totalCompletedPomodoros,
    required this.focusSuccessRate,
  });

  PomodoroState copyWith({
    bool? isRunning,
    bool? isFocus,
    int? remainingSeconds,
    int? focusDuration,
    int? breakDuration,
    String? userLevel,
    int? dailyFocusMinutes,
    int? completedPomodorosToday,
    int? totalCompletedPomodoros,
    double? focusSuccessRate,
  }) {
    return PomodoroState(
      isRunning: isRunning ?? this.isRunning,
      isFocus: isFocus ?? this.isFocus,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      userLevel: userLevel ?? this.userLevel,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      completedPomodorosToday: completedPomodorosToday ?? this.completedPomodorosToday,
      totalCompletedPomodoros: totalCompletedPomodoros ?? this.totalCompletedPomodoros,
      focusSuccessRate: focusSuccessRate ?? this.focusSuccessRate,
    );
  }

  static const PomodoroState initial = PomodoroState(
    isRunning: false,
    isFocus: true,
    remainingSeconds: 25 * 60, // 25 dakika
    focusDuration: 25,
    breakDuration: 5,
    userLevel: 'Başlangıç',
    dailyFocusMinutes: 0,
    completedPomodorosToday: 0,
    totalCompletedPomodoros: 0,
    focusSuccessRate: 100.0,
  );
}