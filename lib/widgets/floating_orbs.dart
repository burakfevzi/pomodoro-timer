import 'package:flutter/material.dart';
import 'dart:math';

class FloatingOrbs extends StatefulWidget {
  final bool isFocus;
  final bool isRunning;

  const FloatingOrbs({
    super.key,
    required this.isFocus,
    required this.isRunning,
  });

  @override
  State<FloatingOrbs> createState() => _FloatingOrbsState();
}

class _FloatingOrbsState extends State<FloatingOrbs>
    with TickerProviderStateMixin {
  late List<AnimationController> _orbitControllers;
  late List<Animation<double>> _orbitAnimations;
  late List<Animation<double>> _wobbleAnimations;
  
  final List<double> _orbitRadii = [120.0, 160.0, 200.0, 240.0, 280.0, 320.0]; // 6 katman
  final int _orbsPerOrbit = 3; // Her yörüngede 3 yuvarlak
  final Random _random = Random();
  
  // Partikül sistemi için
  late List<AnimationController> _particleControllers;
  late List<Animation<double>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _orbitControllers = [];
    _orbitAnimations = [];
    _wobbleAnimations = [];
    _particleControllers = [];
    _particleAnimations = [];

    // Her yörünge için animasyonlar
    for (int orbitIndex = 0; orbitIndex < _orbitRadii.length; orbitIndex++) {
      for (int orbIndex = 0; orbIndex < _orbsPerOrbit; orbIndex++) {
        // Orbit controller - her yörünge farklı hızda (dışa doğru daha yavaş)
        final orbitDuration = Duration(
          milliseconds: 12000 + (orbitIndex * 4000) + _random.nextInt(3000), // 12-27 saniye
        );
        
        final orbitController = AnimationController(
          duration: orbitDuration,
          vsync: this,
        );

        // Orbit animasyonu (0-2π)
        final orbitAnimation = Tween<double>(
          begin: 0.0,
          end: 2 * pi,
        ).animate(CurvedAnimation(
          parent: orbitController,
          curve: Curves.linear,
        ));

        // Wobble animasyonu (organik sapma)
        final wobbleAnimation = Tween<double>(
          begin: -15.0,
          end: 15.0,
        ).animate(CurvedAnimation(
          parent: orbitController,
          curve: Curves.easeInOut,
        ));

        _orbitControllers.add(orbitController);
        _orbitAnimations.add(orbitAnimation);
        _wobbleAnimations.add(wobbleAnimation);

        // Animasyonu başlat
        orbitController.repeat();

        // Her orb için farklı başlangıç pozisyonu
        final startOffset = (orbIndex * pi / _orbsPerOrbit) + (orbitIndex * 0.2);
        Future.delayed(Duration(milliseconds: orbitIndex * 150), () {
          if (mounted) {
            orbitController.forward(from: startOffset / (2 * pi));
          }
        });
      }
    }

    // Partikül animasyonları (arka plan derinliği için)
    for (int i = 0; i < 20; i++) {
      final particleController = AnimationController(
        duration: Duration(milliseconds: 8000 + _random.nextInt(6000)),
        vsync: this,
      );

      final particleAnimation = Tween<double>(
        begin: 0.0,
        end: 2 * pi,
      ).animate(CurvedAnimation(
        parent: particleController,
        curve: Curves.linear,
      ));

      _particleControllers.add(particleController);
      _particleAnimations.add(particleAnimation);

      particleController.repeat();
      
      // Rastgele başlangıç zamanı
      Future.delayed(Duration(milliseconds: _random.nextInt(5000)), () {
        if (mounted) {
          particleController.forward(from: _random.nextDouble());
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _orbitControllers) {
      controller.dispose();
    }
    for (final controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRunning) {
      return const SizedBox.shrink();
    }

    final orbColor = widget.isFocus 
        ? const Color(0xFFFF6B6B) // Kırmızı
        : const Color(0xFF4ECDC4); // Yeşil

    final centerX = MediaQuery.of(context).size.width * 0.5;
    final centerY = MediaQuery.of(context).size.height * 0.5; // Tam ortaya aldık

    return Positioned.fill(
      child: Stack(
        children: [
          // Arka plan partikülleri (3D derinlik hissi için)
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _particleAnimations[index],
              builder: (context, child) {
                final rotation = _particleAnimations[index].value;
                final radius = 50.0 + (_random.nextDouble() * 400); // Rastgele yarıçap
                final depth = _random.nextDouble(); // Derinlik faktörü
                
                final x = centerX + (cos(rotation + index) * radius);
                final y = centerY + (sin(rotation + index) * radius);
                
                return Positioned(
                  left: x - 1,
                  top: y - 1,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orbColor.withOpacity(0.1 * depth),
                      boxShadow: [
                        BoxShadow(
                          color: orbColor.withOpacity(0.05 * depth),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          
          // Yamuk yörünge çizgileri (arka planda)
          ...List.generate(_orbitRadii.length, (orbitIndex) {
            return AnimatedBuilder(
              animation: _orbitAnimations[orbitIndex * _orbsPerOrbit],
              builder: (context, child) {
                final time = _orbitAnimations[orbitIndex * _orbsPerOrbit].value;
                final opacity = 0.12 - (orbitIndex * 0.015); // Dışa doğru daha loş
                
                return CustomPaint(
                  painter: WavyOrbitPainter(
                    center: Offset(centerX, centerY),
                    radius: _orbitRadii[orbitIndex],
                    color: orbColor.withOpacity(opacity),
                    time: time,
                    waveIntensity: 6.0 + (orbitIndex * 1.5), // Dışa doğru daha yamuk
                    depth: orbitIndex / _orbitRadii.length, // 3D derinlik
                  ),
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                );
              },
            );
          }),
          
          // Yörünge üzerindeki yuvarlaklar
          ...List.generate(_orbitRadii.length * _orbsPerOrbit, (index) {
            final orbitIndex = index ~/ _orbsPerOrbit;
            final orbIndex = index % _orbsPerOrbit;
            final animationIndex = index;
            
            return AnimatedBuilder(
              animation: Listenable.merge([
                _orbitAnimations[animationIndex],
                _wobbleAnimations[animationIndex],
              ]),
              builder: (context, child) {
                final rotation = _orbitAnimations[animationIndex].value;
                final wobble = _wobbleAnimations[animationIndex].value;
                
                // Yamuk yörünge üzerindeki pozisyon hesapla
                final baseRadius = _orbitRadii[orbitIndex];
                final waveOffset = sin(rotation * 4 + orbitIndex) * (8.0 + orbitIndex * 2.0);
                final radius = baseRadius + wobble + waveOffset;
                
                final x = centerX + (cos(rotation) * radius);
                final y = centerY + (sin(rotation) * radius);

                // Orb boyutu (yörüngeye göre küçülür)
                final orbSize = 12.0 - (orbitIndex * 2.0) + (sin(rotation * 4) * 2);
                
                // Opacity (dışa doğru daha loş)
                final opacity = 0.3 - (orbitIndex * 0.05);

                return Positioned(
                  left: x - orbSize / 2,
                  top: y - orbSize / 2,
                  child: Container(
                    width: orbSize,
                    height: orbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orbColor.withOpacity(opacity * 0.6),
                      boxShadow: [
                        // İç glow
                        BoxShadow(
                          color: orbColor.withOpacity(opacity * 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                        // Dış glow
                        BoxShadow(
                          color: orbColor.withOpacity(opacity * 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          
          // Hafif ışık parçacıkları (yamuk yörüngelerde)
          ...List.generate(_orbitRadii.length, (orbitIndex) {
            return AnimatedBuilder(
              animation: _orbitAnimations[orbitIndex * _orbsPerOrbit],
              builder: (context, child) {
                final rotation = _orbitAnimations[orbitIndex * _orbsPerOrbit].value;
                final baseRadius = _orbitRadii[orbitIndex];
                
                // Yamuk yörünge üzerindeki ışık pozisyonu
                final waveOffset = sin((rotation + pi) * 4 + orbitIndex) * (8.0 + orbitIndex * 2.0);
                final radius = baseRadius + waveOffset;
                
                final lightX = centerX + (cos(rotation + pi) * radius);
                final lightY = centerY + (sin(rotation + pi) * radius);
                
                return Positioned(
                  left: lightX - 3,
                  top: lightY - 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orbColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: orbColor.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// Yamuk yörünge çizen custom painter
class WavyOrbitPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final double time;
  final double waveIntensity;
  final double depth;

  WavyOrbitPainter({
    required this.center,
    required this.radius,
    required this.color,
    required this.time,
    required this.waveIntensity,
    this.depth = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 + (depth * 0.5); // Derinliğe göre kalınlık

    final path = Path();
    const int segments = 120; // Daha detaylı yörünge
    
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      
      // 3D perspektif efekti
      final perspectiveY = cos(angle) * depth * 0.3;
      
      // Yamuk efekt - sinüs dalgaları ile
      final waveOffset1 = sin(angle * 4 + time * 2) * waveIntensity * 0.4;
      final waveOffset2 = sin(angle * 6 + time * 3) * waveIntensity * 0.3;
      final waveOffset3 = sin(angle * 8 + time * 1.5) * waveIntensity * 0.2;
      final waveOffset4 = sin(angle * 10 + time * 4) * waveIntensity * 0.1;
      
      final currentRadius = radius + waveOffset1 + waveOffset2 + waveOffset3 + waveOffset4;
      
      final x = center.dx + cos(angle) * currentRadius;
      final y = center.dy + sin(angle) * currentRadius + perspectiveY;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Çoklu glow efekti (3D derinlik için)
    for (int i = 0; i < 3; i++) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.03 - (i * 0.01))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (i * 2.0)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0 + (i * 1.5));
      
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(WavyOrbitPainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.color != color ||
           oldDelegate.radius != radius ||
           oldDelegate.depth != depth;
  }
}