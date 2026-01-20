import 'dart:async';
import 'dart:math';

class SoundDetectionService {
  static final SoundDetectionService _instance = SoundDetectionService._internal();
  factory SoundDetectionService() => _instance;
  SoundDetectionService._internal();

  Timer? _detectionTimer;
  StreamController<double>? _volumeController;
  StreamController<bool>? _soundDetectedController;
  
  bool _isEnabled = true;
  bool _isListening = false;
  double _threshold = 0.0015;
  double _currentVolume = 0.0;
  bool _soundDetected = false;
  DateTime? _soundDetectionStart;
  
  // Getters
  bool get isEnabled => _isEnabled;
  bool get isListening => _isListening;
  double get threshold => _threshold;
  double get currentVolume => _currentVolume;
  bool get soundDetected => _soundDetected;
  
  Stream<double> get volumeStream => _volumeController?.stream ?? const Stream.empty();
  Stream<bool> get soundDetectedStream => _soundDetectedController?.stream ?? const Stream.empty();

  Future<bool> initialize() async {
    try {
      _volumeController = StreamController<double>.broadcast();
      _soundDetectedController = StreamController<bool>.broadcast();
      
      print('🎤 Ses algılama servisi başlatıldı (Web simülasyon modu)');
      return true;
    } catch (e) {
      print('❌ Ses algılama başlatma hatası: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    if (_isListening || !_isEnabled) return;

    _isListening = true;
    _startSimulatedMonitoring();
    print('🎤 Ses algılama başladı (Simülasyon - Eşik: $_threshold)');
  }

  void _startSimulatedMonitoring() {
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isListening || !_isEnabled) {
        timer.cancel();
        return;
      }

      _simulateVolumeLevel();
    });
  }

  void _simulateVolumeLevel() {
    // Gerçekçi ses seviyesi simülasyonu
    final random = Random();
    
    // %90 sessizlik, %8 düşük ses, %2 yüksek ses
    final chance = random.nextDouble();
    
    if (chance < 0.90) {
      // Sessizlik
      _currentVolume = random.nextDouble() * 0.0005;
    } else if (chance < 0.98) {
      // Düşük ses
      _currentVolume = 0.0005 + (random.nextDouble() * 0.001);
    } else {
      // Dikkat dağıtıcı yüksek ses
      _currentVolume = _threshold + (random.nextDouble() * 0.003);
    }

    _volumeController?.add(_currentVolume);
    _checkSoundThreshold();
  }

  void _checkSoundThreshold() {
    if (_currentVolume > _threshold) {
      if (!_soundDetected) {
        _soundDetected = true;
        _soundDetectionStart = DateTime.now();
        _soundDetectedController?.add(true);
        print('🔊 Dikkat dağıtıcı ses algılandı! Seviye: ${_currentVolume.toStringAsFixed(4)}');
      }
    } else {
      if (_soundDetected) {
        _soundDetected = false;
        _soundDetectionStart = null;
        _soundDetectedController?.add(false);
        print('🔇 Ses kesildi');
      }
    }
  }

  Duration? getSoundDuration() {
    if (_soundDetectionStart == null) return null;
    return DateTime.now().difference(_soundDetectionStart!);
  }

  void stopListening() {
    _isListening = false;
    _detectionTimer?.cancel();
    _soundDetected = false;
    _soundDetectionStart = null;
    _currentVolume = 0.0;
    print('🔇 Ses algılama durduruldu');
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopListening();
    }
    print('🎤 Ses algılama: ${enabled ? "AÇIK" : "KAPALI"}');
  }

  void setThreshold(double threshold) {
    _threshold = threshold.clamp(0.0005, 0.005);
    print('🎚️ Ses eşiği güncellendi: $_threshold');
  }

  void dispose() {
    stopListening();
    _volumeController?.close();
    _soundDetectedController?.close();
  }
}