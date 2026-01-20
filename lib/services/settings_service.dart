import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SharedPreferences? _prefs;

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Map<String, dynamic> getSettings() {
    if (_prefs == null) return {};
    
    return {
      'focusDuration': _prefs!.getInt('focusDuration') ?? 25,
      'breakDuration': _prefs!.getInt('breakDuration') ?? 5,
      'isFocus': _prefs!.getBool('isFocus') ?? true,
      'userLevel': _prefs!.getString('userLevel') ?? 'Başlangıç',
      'dailyFocusMinutes': _prefs!.getInt('dailyFocusMinutes') ?? 0,
      'completedPomodorosToday': _prefs!.getInt('completedPomodorosToday') ?? 0,
      'totalCompletedPomodoros': _prefs!.getInt('totalCompletedPomodoros') ?? 0,
      'soundEnabled': _prefs!.getBool('soundEnabled') ?? true,
      'soundDetectionEnabled': _prefs!.getBool('soundDetectionEnabled') ?? true,
      'lastDate': _prefs!.getString('lastDate') ?? '',
    };
  }

  Future<void> saveSettings(int focusDuration, int breakDuration, bool isFocus) async {
    if (_prefs == null) return;
    
    await _prefs!.setInt('focusDuration', focusDuration);
    await _prefs!.setInt('breakDuration', breakDuration);
    await _prefs!.setBool('isFocus', isFocus);
  }

  Future<void> saveStats(int dailyMinutes, int completedToday, int totalCompleted, String level) async {
    if (_prefs == null) return;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await _prefs!.setInt('dailyFocusMinutes', dailyMinutes);
    await _prefs!.setInt('completedPomodorosToday', completedToday);
    await _prefs!.setInt('totalCompletedPomodoros', totalCompleted);
    await _prefs!.setString('userLevel', level);
    await _prefs!.setString('lastDate', today);
  }

  bool shouldResetDaily() {
    if (_prefs == null) return false;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs!.getString('lastDate') ?? '';
    
    return today != lastDate;
  }

  Future<void> resetDailyStats() async {
    if (_prefs == null) return;
    
    await _prefs!.setInt('dailyFocusMinutes', 0);
    await _prefs!.setInt('completedPomodorosToday', 0);
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs!.setString('lastDate', today);
  }

  // Haftalık istatistikler için yeni fonksiyonlar
  Map<String, dynamic> getWeeklyStats() {
    if (_prefs == null) return {};
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    int weeklyFocusMinutes = 0;
    int weeklyCompletedPomodoros = 0;
    int totalAttempts = 0;
    
    // Son 7 günün verilerini topla
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i)).toIso8601String().split('T')[0];
      weeklyFocusMinutes += _prefs!.getInt('daily_focus_$date') ?? 0;
      weeklyCompletedPomodoros += _prefs!.getInt('daily_pomodoros_$date') ?? 0;
      totalAttempts += _prefs!.getInt('daily_attempts_$date') ?? 0;
    }
    
    final successRate = totalAttempts > 0 ? weeklyCompletedPomodoros / totalAttempts : 0.0;
    
    return {
      'weeklyFocusMinutes': weeklyFocusMinutes,
      'weeklyCompletedPomodoros': weeklyCompletedPomodoros,
      'weeklySuccessRate': successRate,
      'totalAttempts': totalAttempts,
    };
  }

  Future<void> saveDailyStats(int focusMinutes, int completedPomodoros, int attempts) async {
    if (_prefs == null) return;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await _prefs!.setInt('daily_focus_$today', focusMinutes);
    await _prefs!.setInt('daily_pomodoros_$today', completedPomodoros);
    await _prefs!.setInt('daily_attempts_$today', attempts);
  }

  List<Map<String, dynamic>> getWeeklyHistory() {
    if (_prefs == null) return [];
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      weekData.add({
        'date': dateStr,
        'dayName': _getDayName(date.weekday),
        'focusMinutes': _prefs!.getInt('daily_focus_$dateStr') ?? 0,
        'completedPomodoros': _prefs!.getInt('daily_pomodoros_$dateStr') ?? 0,
        'attempts': _prefs!.getInt('daily_attempts_$dateStr') ?? 0,
      });
    }
    
    return weekData;
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }
}