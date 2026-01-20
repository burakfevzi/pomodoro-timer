import 'package:flutter/material.dart';

class BreakNotification extends StatefulWidget {
  final bool isVisible;
  final int breakMinutes;
  final VoidCallback onDismiss;

  const BreakNotification({
    super.key,
    required this.isVisible,
    required this.breakMinutes,
    required this.onDismiss,
  });

  @override
  State<BreakNotification> createState() => _BreakNotificationState();
}

class _BreakNotificationState extends State<BreakNotification>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(BreakNotification oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible && !oldWidget.isVisible) {
      _scaleController.forward();
      _glowController.repeat(reverse: true);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _scaleController.reverse();
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(_glowAnimation.value * 0.6),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mola ikonu
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4ECDC4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.coffee,
                          size: 40,
                          color: Color(0xFF4ECDC4),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Başlık
                      const Text(
                        'Odaklanma Tamamlandı!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Mola süresi
                      Text(
                        '${widget.breakMinutes} dakika mola zamanı',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Açıklama
                      Text(
                        'Biraz dinlen, su iç ve geri dön!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Başlat butonu
                      ElevatedButton(
                        onPressed: widget.onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Molayı Başlat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}