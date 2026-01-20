import 'package:flutter/material.dart';
import 'flip_digit.dart';
import 'dart:math';

class FlipClock extends StatefulWidget {
  final int minutes;
  final int seconds;
  final bool isFocus;

  const FlipClock({
    super.key,
    required this.minutes,
    required this.seconds,
    required this.isFocus,
  });

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> with TickerProviderStateMixin {
  int _previousMinutes = -1;
  int _previousSeconds = -1;
  
  // Mikro animasyonlar için
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _lightController;
  
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _lightAnimation;

  @override
  void initState() {
    super.initState();
    
    // Dalga animasyonu
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    // Pulse animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Işık çizgileri animasyonu
    _lightController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _lightAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _lightController,
      curve: Curves.linear,
    ));
    
    // Animasyonları başlat
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
    _lightController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Değişim kontrolü
    final minutesChanged = _previousMinutes != widget.minutes;
    final secondsChanged = _previousSeconds != widget.seconds;

    // Önceki değerleri güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousMinutes = widget.minutes;
      _previousSeconds = widget.seconds;
    });

    final clockColor = widget.isFocus 
        ? const Color(0xFFFF6B6B) 
        : const Color(0xFF4ECDC4);

    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _pulseAnimation, _lightAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Arka plan dalgaları
            CustomPaint(
              painter: WaveRingsPainter(
                color: clockColor,
                wavePhase: _waveAnimation.value,
                pulseIntensity: _pulseAnimation.value,
              ),
              size: const Size(400, 300),
            ),
            
            // Dönen ışık çizgileri
            CustomPaint(
              painter: LightRaysPainter(
                color: clockColor,
                rotation: _lightAnimation.value,
                intensity: _pulseAnimation.value,
              ),
              size: const Size(500, 350),
            ),
            
            // Ana sayaç container'ı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  // Ana gölge
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                  // Renkli glow
                  BoxShadow(
                    color: clockColor.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dakika - Onlar basamağı
                  FlipDigit(
                    value: widget.minutes ~/ 10,
                    shouldFlip: minutesChanged,
                    isFocus: widget.isFocus,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Dakika - Birler basamağı
                  FlipDigit(
                    value: widget.minutes % 10,
                    shouldFlip: minutesChanged,
                    isFocus: widget.isFocus,
                  ),
                  
                  const SizedBox(width: 30),
                  
                  // İki nokta ayırıcı (animasyonlu)
                  Container(
                    width: 10,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8 + (_pulseAnimation.value - 1) * 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: clockColor.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8 + (_pulseAnimation.value - 1) * 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: clockColor.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 30),
                  
                  // Saniye - Onlar basamağı
                  FlipDigit(
                    value: widget.seconds ~/ 10,
                    shouldFlip: secondsChanged,
                    isFocus: widget.isFocus,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Saniye - Birler basamağı
                  FlipDigit(
                    value: widget.seconds % 10,
                    shouldFlip: secondsChanged,
                    isFocus: widget.isFocus,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Dalga halkaları çizen painter
class WaveRingsPainter extends CustomPainter {
  final Color color;
  final double wavePhase;
  final double pulseIntensity;

  WaveRingsPainter({
    required this.color,
    required this.wavePhase,
    required this.pulseIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 3 dalga halkası
    for (int i = 0; i < 3; i++) {
      final radius = (60.0 + (i * 25)) * pulseIntensity;
      final opacity = (0.15 - (i * 0.04)) * (2 - pulseIntensity);
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      
      // Dalga efekti
      final path = Path();
      const segments = 60;
      
      for (int j = 0; j <= segments; j++) {
        final angle = (j / segments) * 2 * pi;
        final waveOffset = sin(angle * 4 + wavePhase + (i * 0.5)) * 8;
        final currentRadius = radius + waveOffset;
        
        final x = center.dx + cos(angle) * currentRadius;
        final y = center.dy + sin(angle) * currentRadius;
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveRingsPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
           oldDelegate.pulseIntensity != pulseIntensity;
  }
}

// Işık çizgileri çizen painter
class LightRaysPainter extends CustomPainter {
  final Color color;
  final double rotation;
  final double intensity;

  LightRaysPainter({
    required this.color,
    required this.rotation,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 6 ışık çizgisi
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + rotation;
      final length = 80.0 * intensity;
      
      final startRadius = 120.0;
      final endRadius = startRadius + length;
      
      final startX = center.dx + cos(angle) * startRadius;
      final startY = center.dy + sin(angle) * startRadius;
      final endX = center.dx + cos(angle) * endRadius;
      final endY = center.dy + sin(angle) * endRadius;
      
      final paint = Paint()
        ..color = color.withOpacity(0.1 * (2 - intensity))
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.intensity != intensity;
  }
}