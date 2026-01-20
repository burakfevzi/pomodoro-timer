class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> playNotificationSound() async {
    if (!_soundEnabled) return;
    
    // Web için basit console log
    print('🔔 Bildirim sesi çalındı!');
  }

  Future<void> playWarningSound() async {
    if (!_soundEnabled) return;
    
    print('⚠️ Uyarı sesi çalındı!');
  }

  Future<void> playCompletionSound(bool isFocusComplete) async {
    if (!_soundEnabled) return;
    
    final message = isFocusComplete 
        ? '🎉 Odak tamamlandı!' 
        : '⏰ Mola bitti!';
    print(message);
  }

  void dispose() {
    // Artık dispose edilecek bir şey yok
  }
}