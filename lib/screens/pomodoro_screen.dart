import 'package:flutter/material.dart';
import '../widgets/flip_clock.dart';
import '../widgets/phase_indicator.dart';
import '../widgets/level_indicator.dart';
import '../widgets/floating_orbs.dart';
import '../widgets/break_notification.dart';
import '../models/pomodoro_state.dart';
import '../services/timer_service.dart';
import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../services/sound_detection_service.dart';
import 'settings_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  late TimerService _timerService;
  late SettingsService _settingsService;
  late AudioService _audioService;
  late SoundDetectionService _soundDetectionService;
  
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _showBreakNotification = false;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _timerService = TimerService(_settingsService);
    _audioService = AudioService();
    _soundDetectionService = SoundDetectionService();
    
    // Ses algılama servisini başlat
    _soundDetectionService.initialize();
    
    // Glow animasyon controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Pulse animasyon controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shake animasyon controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _loadSettings();
    
    // Timer tamamlandığında ses çal
    _timerService.stateStream.listen((state) {
      if (state.remainingSeconds == 0 && !state.isRunning) {
        _audioService.playCompletionSound(state.isFocus);
        _triggerCompletionAnimation();
        
        // Eğer odak tamamlandıysa mola bildirimi göster
        if (state.isFocus) {
          setState(() {
            _showBreakNotification = true;
          });
        }
      }
    });
  }

  Future<void> _loadSettings() async {
    await _settingsService.loadSettings();
    _timerService.loadFromSettings();
    setState(() {});
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _timerService.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timerService.isRunning) {
      _timerService.pauseTimer();
      _glowController.stop();
      _pulseController.stop();
    } else {
      _timerService.startTimer();
      _glowController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    }
    setState(() {});
  }

  void _triggerCompletionAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _startBreak() {
    setState(() {
      _showBreakNotification = false;
    });
    _timerService.switchPhase(); // Molaya geç
    _toggleTimer(); // Molayı başlat
  }

  void _openSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            SettingsScreen(
              settingsService: _settingsService,
              timerService: _timerService,
              soundDetectionService: _soundDetectionService,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF161616),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<PomodoroState>(
            stream: _timerService.stateStream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? _timerService.currentState;
              
              return Stack(
                children: [
                  // Floating orbs (arka planda)
                  FloatingOrbs(
                    isFocus: state.isFocus,
                    isRunning: state.isRunning,
                  ),
                  
                  // Ana içerik
                  Column(
                    children: [
                      // Header with settings button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48),
                            const Text(
                              'Pomodoro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                              ),
                            ),
                            IconButton(
                              onPressed: _openSettings,
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Durum göstergesi
                      PhaseIndicator(
                        isRunning: state.isRunning,
                        isFocus: state.isFocus,
                      ),
                      
                      // Merkezi alan - sayaç burada
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Türkçe tarih ve saat
                              StreamBuilder<DateTime>(
                                stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                                builder: (context, snapshot) {
                                  final now = snapshot.data ?? DateTime.now();
                                  final months = [
                                    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
                                  ];
                                  final days = [
                                    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
                                  ];
                                  
                                  final dayName = days[now.weekday - 1];
                                  final monthName = months[now.month - 1];
                                  final dateStr = '$dayName, ${now.day} $monthName ${now.year}';
                                  final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                                  
                                  return Column(
                                    children: [
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'SF Mono',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Flip Clock with animations
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _glowAnimation,
                                  _pulseAnimation,
                                  _shakeAnimation,
                                ]),
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _shakeAnimation.value * 
                                      ((_shakeController.value * 4).round() % 2 == 0 ? 1 : -1),
                                      0,
                                    ),
                                    child: Transform.scale(
                                      scale: state.isRunning ? _pulseAnimation.value : 1.0,
                                      child: GestureDetector(
                                        onTap: _toggleTimer,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: state.isRunning ? [
                                              BoxShadow(
                                                color: (state.isFocus 
                                                    ? const Color(0xFFFF6B6B) 
                                                    : const Color(0xFF4ECDC4))
                                                    .withOpacity(_glowAnimation.value * 0.6),
                                                blurRadius: 50,
                                                spreadRadius: 10,
                                              ),
                                            ] : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: FlipClock(
                                            minutes: state.remainingSeconds ~/ 60,
                                            seconds: state.remainingSeconds % 60,
                                            isFocus: state.isFocus,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Talimat
                              AnimatedOpacity(
                                opacity: state.isRunning ? 0.3 : 0.8,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  state.isRunning 
                                      ? 'Durdurmak için sayaca dokunun'
                                      : 'Başlatmak için sayaca dokunun',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Alt kısım - seviye göstergesi
                      LevelIndicator(
                        level: state.userLevel,
                        dailyMinutes: state.dailyFocusMinutes,
                        completedPomodoros: state.completedPomodorosToday,
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                  
                  // Mola bildirimi
                  BreakNotification(
                    isVisible: _showBreakNotification,
                    breakMinutes: _timerService.currentState.isFocus 
                        ? _settingsService.getSettings()['breakDuration'] ?? 5
                        : _settingsService.getSettings()['focusDuration'] ?? 25,
                    onDismiss: _startBreak,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}