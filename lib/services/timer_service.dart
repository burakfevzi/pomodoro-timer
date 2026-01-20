import 'dart:async';
import '../models/pomodoro_state.dart';
import 'settings_service.dart';

class TimerService {
  final SettingsService _settingsService;
  Timer? _timer;
  
  PomodoroState _currentState = PomodoroState.initial;
  final StreamController<PomodoroState> _stateController = 
      StreamController<PomodoroState>.broadcast();

  TimerService(this._settingsService);

  Stream<PomodoroState> get stateStream => _stateController.stream;
  PomodoroState get currentState => _currentState;
  bool get isRunning => _currentState.isRunning;

  void startTimer() {
    if (_currentState.isRunning) return;

    _updateState(_currentState.copyWith(isRunning: true));
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentState.remainingSeconds > 0) {
        _updateState(_currentState.copyWith(
          remainingSeconds: _currentState.remainingSeconds - 1,
        ));
      } else {
        _completePhase();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _updateState(_currentState.copyWith(isRunning: false));
  }

  void switchPhase() {
    // Manuel olarak faz değiştir (Odak → Mola veya Mola → Odak)
    final newIsFocus = !_currentState.isFocus;
    final newDuration = newIsFocus 
        ? _currentState.focusDuration 
        : _currentState.breakDuration;
    
    _updateState(_currentState.copyWith(
      isRunning: false,
      isFocus: newIsFocus,
      remainingSeconds: newDuration * 60,
    ));
  }

  void _completePhase() {
    _timer?.cancel();
    
    // İstatistikleri güncelle (sadece odak seansları için)
    if (_currentState.isFocus) {
      final newDailyMinutes = _currentState.dailyFocusMinutes + _currentState.focusDuration;
      final newCompletedPomodoros = _currentState.completedPomodorosToday + 1;
      final newTotalPomodoros = _currentState.totalCompletedPomodoros + 1;
      
      // Kullanıcı seviyesini hesapla
      final newLevel = _calculateUserLevel(newDailyMinutes, newCompletedPomodoros);
      
      _updateState(_currentState.copyWith(
        dailyFocusMinutes: newDailyMinutes,
        completedPomodorosToday: newCompletedPomodoros,
        totalCompletedPomodoros: newTotalPomodoros,
        userLevel: newLevel,
      ));
      
      // Ayarları kaydet
      _settingsService.saveStats(
        newDailyMinutes,
        newCompletedPomodoros,
        newTotalPomodoros,
        newLevel,
      );
    }

    // Durum değiştir (Odak → Mola veya Mola → Odak)
    final newIsFocus = !_currentState.isFocus;
    final newDuration = newIsFocus 
        ? _currentState.focusDuration 
        : _currentState.breakDuration;
    
    _updateState(_currentState.copyWith(
      isRunning: false,
      isFocus: newIsFocus,
      remainingSeconds: newDuration * 60,
    ));
  }

  String _calculateUserLevel(int dailyMinutes, int completedPomodoros) {
    if (dailyMinutes >= 120 && completedPomodoros >= 6) {
      return 'Disiplinli';
    } else if (dailyMinutes >= 60 && completedPomodoros >= 3) {
      return 'Orta';
    } else {
      return 'Başlangıç';
    }
  }

  void updateSettings(int focusDuration, int breakDuration) {
    final newRemainingSeconds = _currentState.isFocus 
        ? focusDuration * 60 
        : breakDuration * 60;
    
    _updateState(_currentState.copyWith(
      focusDuration: focusDuration,
      breakDuration: breakDuration,
      remainingSeconds: _currentState.isRunning 
          ? _currentState.remainingSeconds 
          : newRemainingSeconds,
    ));
  }

  void loadFromSettings() {
    final settings = _settingsService.getSettings();
    
    _updateState(_currentState.copyWith(
      focusDuration: settings['focusDuration'] ?? 25,
      breakDuration: settings['breakDuration'] ?? 5,
      isFocus: settings['isFocus'] ?? true,
      userLevel: settings['userLevel'] ?? 'Başlangıç',
      dailyFocusMinutes: settings['dailyFocusMinutes'] ?? 0,
      completedPomodorosToday: settings['completedPomodorosToday'] ?? 0,
      totalCompletedPomodoros: settings['totalCompletedPomodoros'] ?? 0,
    ));
    
    // Kalan süreyi ayarla
    final duration = _currentState.isFocus 
        ? _currentState.focusDuration 
        : _currentState.breakDuration;
    
    _updateState(_currentState.copyWith(
      remainingSeconds: duration * 60,
    ));
  }

  void _updateState(PomodoroState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}