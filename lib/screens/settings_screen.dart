import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/timer_service.dart';
import '../services/sound_detection_service.dart';
import '../widgets/animated_slider.dart';
import '../widgets/ai_suggestions.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final TimerService timerService;
  final SoundDetectionService? soundDetectionService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.timerService,
    this.soundDetectionService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  int _focusDuration = 25;
  int _breakDuration = 5;
  bool _soundEnabled = true;
  bool _soundDetectionEnabled = true;
  
  // Admin panel için saniye cinsinden değerler
  int _focusSeconds = 0;
  int _breakSeconds = 0;
  bool _isAdminMode = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Sağdan gelsin
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic, // Düz animasyon
    ));
    
    _loadSettings();
    _slideController.forward();
  }

  void _loadSettings() {
    final settings = widget.settingsService.getSettings();
    setState(() {
      _focusDuration = (settings['focusDuration'] ?? 25).clamp(5, 60);
      _breakDuration = (settings['breakDuration'] ?? 5).clamp(3, 20);
      _soundEnabled = settings['soundEnabled'] ?? true;
      _soundDetectionEnabled = settings['soundDetectionEnabled'] ?? true;
    });
    
    // Ses algılama servisini başlat
    if (widget.soundDetectionService != null) {
      widget.soundDetectionService!.setEnabled(_soundDetectionEnabled);
      if (_soundDetectionEnabled) {
        widget.soundDetectionService!.startListening();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A1A),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white70,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Ayarlar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Admin butonu
                      IconButton(
                        onPressed: _showAdminPanel,
                        icon: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // AI Önerileri
                        _buildGlassContainer(
                          child: AISuggestions(
                            settingsService: widget.settingsService,
                            onSuggestionsReceived: (focus, breakTime) {
                              setState(() {
                                _focusDuration = focus;
                                _breakDuration = breakTime;
                              });
                              _saveSettings();
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Manuel Ayarlar
                        _buildGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Manuel Ayarlar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // Odak Süresi
                              AnimatedSlider(
                                title: 'Odak Süresi',
                                value: _focusDuration.toDouble(),
                                min: 5,
                                max: 60,
                                divisions: 55,
                                color: const Color(0xFFFF6B6B),
                                suffix: 'dakika',
                                onChanged: (value) {
                                  setState(() {
                                    _focusDuration = value.round();
                                  });
                                  _saveSettings();
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Mola Süresi
                              AnimatedSlider(
                                title: 'Mola Süresi',
                                value: _breakDuration.toDouble(),
                                min: 3,
                                max: 20,
                                divisions: 17,
                                color: const Color(0xFF4ECDC4),
                                suffix: 'dakika',
                                onChanged: (value) {
                                  setState(() {
                                    _breakDuration = value.round();
                                  });
                                  _saveSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Ses Ayarları
                        _buildGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ses Bildirimleri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Bildirim Sesleri',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Switch(
                                    value: _soundEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _soundEnabled = value;
                                      });
                                      _saveSettings();
                                    },
                                    activeColor: const Color(0xFF4ECDC4),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 10),
                              
                              Text(
                                'Süre tamamlandığında bildirim sesi çalar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Ses Algılama Sistemi
                        _buildGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ses Algılama Sistemi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Ses Algılama',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Switch(
                                    value: _soundDetectionEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _soundDetectionEnabled = value;
                                      });
                                      widget.soundDetectionService?.setEnabled(value);
                                      if (value) {
                                        widget.soundDetectionService?.startListening();
                                      } else {
                                        widget.soundDetectionService?.stopListening();
                                      }
                                      _saveSettings();
                                    },
                                    activeColor: const Color(0xFFFFEB3B),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 15),
                              
                              Text(
                                'Dikkat dağıtıcı sesleri algılar ve 12 saniye sonra sayacı durdurur',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              
                              if (_soundDetectionEnabled && widget.soundDetectionService != null) ...[
                                const SizedBox(height: 20),
                                
                                // Ses seviyesi göstergesi
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEB3B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFEB3B).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Anlık Ses Seviyesi:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          StreamBuilder<double>(
                                            stream: widget.soundDetectionService!.volumeStream,
                                            builder: (context, snapshot) {
                                              final volume = snapshot.data ?? 0.0;
                                              return Text(
                                                '${(volume * 1000).toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: volume > widget.soundDetectionService!.threshold
                                                      ? const Color(0xFFFF6B6B)
                                                      : const Color(0xFF4ECDC4),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      StreamBuilder<double>(
                                        stream: widget.soundDetectionService!.volumeStream,
                                        builder: (context, snapshot) {
                                          final volume = snapshot.data ?? 0.0;
                                          return LinearProgressIndicator(
                                            value: (volume / 0.005).clamp(0.0, 1.0),
                                            backgroundColor: Colors.white.withOpacity(0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              volume > widget.soundDetectionService!.threshold
                                                  ? const Color(0xFFFF6B6B)
                                                  : const Color(0xFF4ECDC4),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      StreamBuilder<bool>(
                                        stream: widget.soundDetectionService!.soundDetectedStream,
                                        builder: (context, snapshot) {
                                          final detected = snapshot.data ?? false;
                                          return Text(
                                            detected ? '🔊 Ses algılandı!' : '🔇 Sessiz',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: detected 
                                                  ? const Color(0xFFFF6B6B)
                                                  : Colors.white.withOpacity(0.6),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showAdminPanel() {
    setState(() {
      _focusSeconds = _focusDuration * 60;
      _breakSeconds = _breakDuration * 60;
    });
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Odak süresi (saniye)
                Text(
                  'Odak Süresi: ${_focusSeconds} saniye',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Slider(
                  value: _focusSeconds.toDouble(),
                  min: 10,
                  max: 3600, // 1 saat
                  divisions: 359,
                  activeColor: const Color(0xFFFF6B6B),
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setDialogState(() {
                      _focusSeconds = value.round();
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Mola süresi (saniye)
                Text(
                  'Mola Süresi: ${_breakSeconds} saniye',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Slider(
                  value: _breakSeconds.toDouble(),
                  min: 5,
                  max: 1200, // 20 dakika
                  divisions: 239,
                  activeColor: const Color(0xFF4ECDC4),
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setDialogState(() {
                      _breakSeconds = value.round();
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Bu ayarlar sadece test amaçlıdır.\nNormal kullanım için dakika ayarlarını kullanın.',
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Admin modunda saniye değerlerini dakikaya çevir ama minimum değerleri koru
                  _focusDuration = ((_focusSeconds / 60.0).round()).clamp(1, 60);
                  _breakDuration = ((_breakSeconds / 60.0).round()).clamp(1, 20);
                  _isAdminMode = true;
                });
                _saveAdminSettings();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAdminSettings() {
    // Admin modunda saniye cinsinden kaydet - dakikaya çevirmeden direkt saniye olarak
    final focusMinutes = _focusDuration.clamp(1, 60);
    final breakMinutes = _breakDuration.clamp(1, 20);
    
    widget.settingsService.saveSettings(focusMinutes, breakMinutes, true);
    widget.timerService.updateSettings(focusMinutes, breakMinutes);
  }

  void _saveSettings() {
    widget.settingsService.saveSettings(_focusDuration, _breakDuration, true);
    widget.timerService.updateSettings(_focusDuration, _breakDuration);
  }
}